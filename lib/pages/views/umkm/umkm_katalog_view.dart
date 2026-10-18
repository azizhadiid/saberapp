import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'umkm_add_supply_dialog.dart';

/// ============================================================================
/// KATALOG PASOKAN SCRAP & BAHAN BAKU SIRKULAR (UMKM & PERUSAHAAN HIJAU)
/// Terhubung Dinamis dengan Supabase Database (Tabel: umkm_supplies)
/// ============================================================================
class UmkmKatalogView extends StatefulWidget {
  final VoidCallback onAddSupply;

  const UmkmKatalogView({super.key, required this.onAddSupply});

  @override
  State<UmkmKatalogView> createState() => _UmkmKatalogViewState();
}

class _UmkmKatalogViewState extends State<UmkmKatalogView> {
  String _selectedCategory = 'Semua Kategori';
  bool _isLoading = true;
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';
  String? _companyName;
  bool _isShowingUserSuppliesOnly = false;

  final List<String> _categories = [
    'Semua Kategori',
    'Scrap HMS 1&2',
    'Shredded Scrap MRF',
    'Prompt Industrial Scrap',
    'Bahan Baku Biomassa',
    'Teknologi EAF & Filter',
  ];

  List<Map<String, dynamic>> _mySupplyList = [];

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() {
      setState(() {
        _searchQuery = _searchCtrl.text.trim().toLowerCase();
      });
    });
    _fetchSupplies();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  /// Membaca daftar pasokan secara dinamis dari Supabase (tabel: umkm_supplies)
  /// Terhubung relasional dengan user dan perusahaan (tabel: companies) yang login
  Future<void> _fetchSupplies() async {
    setState(() => _isLoading = true);
    try {
      final currentUser = Supabase.instance.client.auth.currentUser;
      String? compName;
      String? compId;

      if (currentUser != null) {
        try {
          final compRes = await Supabase.instance.client
              .from('companies')
              .select('id, name, role')
              .eq('user_id', currentUser.id)
              .maybeSingle();

          if (compRes != null) {
            compId = compRes['id']?.toString();
            compName = compRes['name']?.toString();
          }
        } catch (e) {
          debugPrint('Info query company: $e');
        }
      }

      List<Map<String, dynamic>> dbItems = [];

      // 1. Coba ambil pasokan spesifik milik akun/perusahaan yang login
      if (currentUser != null) {
        try {
          final userResponse = await Supabase.instance.client
              .from('umkm_supplies')
              .select()
              .or('user_id.eq.${currentUser.id}${compId != null ? ',company_id.eq.$compId' : ''}')
              .order('created_at', ascending: false);

          final userList = List<Map<String, dynamic>>.from(userResponse);
          if (userList.isNotEmpty) {
            dbItems = userList;
            _isShowingUserSuppliesOnly = true;
          }
        } catch (e) {
          debugPrint('Info query user supplies: $e');
        }
      }

      // 2. Jika user belum memiliki pasokan sendiri, ambil pasokan bursa/template
      if (dbItems.isEmpty) {
        try {
          final publicResponse = await Supabase.instance.client
              .from('umkm_supplies')
              .select()
              .order('created_at', ascending: false);

          final publicList = List<Map<String, dynamic>>.from(publicResponse);
          if (publicList.isNotEmpty) {
            dbItems = publicList;
            _isShowingUserSuppliesOnly = false;
          }
        } catch (e) {
          debugPrint('Info query public supplies: $e');
        }
      }

      if (mounted) {
        setState(() {
          _companyName = compName;
          _mySupplyList = dbItems;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Catatan Supabase umkm_supplies: $e');
      if (mounted) {
        setState(() {
          _mySupplyList = [];
          _isLoading = false;
        });
      }
    }
  }

  /// Membuka form tambah pasokan baru & langsung sinkronisasi dinamis
  Future<void> _openAddNewSupply() async {
    final newSupply = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const UmkmAddSupplyDialog(),
    );

    if (newSupply != null && mounted) {
      setState(() {
        _mySupplyList.insert(0, newSupply);
      });
      // Sinkronisasi ulang dengan database
      _fetchSupplies();
    }
  }

  /// Bottom Sheet Info Harga Patokan Scrap Logam Nasional
  void _showMarketPriceBenchmarks() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
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
                    child: const Icon(Icons.trending_up_rounded, color: Color(0xFF0284C7), size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Harga Patokan Scrap Nasional (ICDX)',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          'Acuan harga lebur pabrik baja EAF per Oktober 2026',
                          style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildPriceRow('Heavy Melting Steel (HMS 1)', 'Rp 7.000 - Rp 7.200 / kg', 'Fe > 98.2%'),
              const Divider(height: 16),
              _buildPriceRow('Shredded Scrap Otomotif (MRF)', 'Rp 7.250 - Rp 7.450 / kg', 'Densitas > 0.9 t/m³'),
              const Divider(height: 16),
              _buildPriceRow('New Prompt Busheling Scrap', 'Rp 7.450 - Rp 7.600 / kg', 'Cu < 0.05% (Bersih)'),
              const Divider(height: 16),
              _buildPriceRow('Briket Cangkang Sawit (Biomassa)', 'Rp 2.100 - Rp 2.300 / kg', 'Kalor > 4.500 kkal'),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0284C7),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Tutup Informasi Acuan', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, String price, String note) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
            Text(note, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
          ],
        ),
        Text(price, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF059669))),
      ],
    );
  }

  /// Dialog Cepat Edit Stok & Harga Penawaran ke Supabase
  void _showUpdateStockDialog(Map<String, dynamic> item) {
    final tonnageCtrl = TextEditingController(text: item['tonnage_available']?.toString() ?? '100');
    final priceCtrl = TextEditingController(text: item['price_per_ton']?.toString() ?? '6800000');
    String currentStatus = item['status'] ?? 'Siap Kirim';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
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
                    child: const Icon(Icons.edit_note_rounded, color: Color(0xFF0284C7), size: 22),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Perbarui Stok & Harga Pasokan',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                        ),
                        Text(
                          item['title'] ?? 'Lot Pasokan',
                          style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: tonnageCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Volume Stok Tersedia (Ton)',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: priceCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Harga Penawaran / Ton (Rp)',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: currentStatus,
                decoration: InputDecoration(
                  labelText: 'Status Pasokan',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                items: const [
                  DropdownMenuItem(value: 'Siap Kirim', child: Text('Siap Kirim')),
                  DropdownMenuItem(value: 'Tersedia Terbatas', child: Text('Tersedia Terbatas')),
                  DropdownMenuItem(value: 'Pre-Order / Kontrak', child: Text('Pre-Order / Kontrak')),
                  DropdownMenuItem(value: 'Habis Terjual', child: Text('Habis Terjual')),
                ],
                onChanged: (val) {
                  if (val != null) setModalState(() => currentStatus = val);
                },
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: () async {
                      final nav = Navigator.of(ctx);
                      final messenger = ScaffoldMessenger.of(context);
                      final confirm = await showDialog<bool>(
                        context: ctx,
                        builder: (dCtx) => AlertDialog(
                          title: const Text('Hapus Pasokan?'),
                          content: Text('Apakah Anda yakin ingin menghapus lot "${item['title']}" secara permanen dari database?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(dCtx, false),
                              child: const Text('Batal'),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(dCtx, true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFEF4444),
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Hapus Permanen'),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        nav.pop();
                        setState(() {
                          _mySupplyList.removeWhere((el) => el['id'] == item['id']);
                        });
                        if (item['id'] != null) {
                          try {
                            await Supabase.instance.client
                                .from('umkm_supplies')
                                .delete()
                                .eq('id', item['id']);
                          } catch (e) {
                            debugPrint('Gagal hapus dari Supabase: $e');
                          }
                        }
                        if (mounted) {
                          messenger.showSnackBar(
                            const SnackBar(
                              content: Text('Pasokan berhasil dihapus dari database!'),
                              backgroundColor: Color(0xFFEF4444),
                            ),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444), size: 18),
                    label: const Text('Hapus Lot', style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold)),
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Batal', style: TextStyle(color: Color(0xFF64748B))),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () async {
                          final newTonnage = num.tryParse(tonnageCtrl.text) ?? item['tonnage_available'];
                          final newPrice = num.tryParse(priceCtrl.text) ?? item['price_per_ton'];
                          final newCo2 = (newTonnage * 1.42).roundToDouble();
                          final messenger = ScaffoldMessenger.of(context);

                          // Update state lokal
                          setState(() {
                            item['tonnage_available'] = newTonnage;
                            item['price_per_ton'] = newPrice;
                            item['co2_saved_ton'] = newCo2;
                            item['status'] = currentStatus;
                          });

                          Navigator.pop(ctx);

                          // Update ke Supabase jika ada id valid
                          if (item['id'] != null) {
                            try {
                              await Supabase.instance.client
                                  .from('umkm_supplies')
                                  .update({
                                    'tonnage_available': newTonnage,
                                    'price_per_ton': newPrice,
                                    'co2_saved_ton': newCo2,
                                    'status': currentStatus,
                                  })
                                  .eq('id', item['id']);
                            } catch (e) {
                              debugPrint('Gagal update ke Supabase: $e');
                            }
                          }

                          if (mounted) {
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text('Data stok pasokan berhasil diperbarui!'),
                                backgroundColor: Color(0xFF0284C7),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0284C7),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Simpan Perubahan', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Dialog Cepat Tawarkan Langsung ke Pabrik Baja (B2B Matchmaking)
  void _showOfferToMillsDialog(Map<String, dynamic> item) {
    final List<String> partnerMills = [
      'PT Krakatau Steel (Persero) Tbk (Cilegon)',
      'PT Gunung Raja Paksi Tbk (Cikarang)',
      'PT Bhirawa Steel (Surabaya)',
      'PT Ispat Indo (Sidoarjo)',
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.handshake_rounded, color: Color(0xFF059669), size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tawarkan Pasokan ke Pabrik Baja Mitra',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                        ),
                        Text(
                          'Kirim penawaran resmi langsung ke tim pengadaan EAF',
                          style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Text(
                'Pilih Pabrik Baja Tujuan:',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
              ),
              const SizedBox(height: 8),
              ...partnerMills.map(
                (mill) => ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.factory_rounded, color: Color(0xFF0284C7), size: 20),
                  title: Text(mill, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                  trailing: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Penawaran lot "${item['title']}" berhasil dikirimkan ke $mill!'),
                          backgroundColor: const Color(0xFF059669),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF059669),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Kirim RFQ', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final currencyCompact = NumberFormat.compactCurrency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 1,
    );

    // Filter dinamis berdasarkan kategori & kata kunci pencarian
    final filteredList = _mySupplyList.where((item) {
      final categoryMatch = _selectedCategory == 'Semua Kategori' || item['category'] == _selectedCategory;
      if (!categoryMatch) return false;

      if (_searchQuery.isEmpty) return true;
      final title = (item['title'] ?? '').toString().toLowerCase();
      final depo = (item['depo'] ?? '').toString().toLowerCase();
      final category = (item['category'] ?? '').toString().toLowerCase();

      return title.contains(_searchQuery) || depo.contains(_searchQuery) || category.contains(_searchQuery);
    }).toList();

    // Kalkulasi Dinamis Kinerja Inventaris Pasokan
    final double totalCo2Saved = _mySupplyList.fold<double>(
      0,
      (sum, item) => sum + (num.tryParse(item['co2_saved_ton']?.toString() ?? '0') ?? 0).toDouble(),
    );
    final double totalStock = _mySupplyList.fold<double>(
      0,
      (sum, item) => sum + (num.tryParse(item['tonnage_available']?.toString() ?? '0') ?? 0).toDouble(),
    );
    final double totalEstimatedValue = _mySupplyList.fold<double>(
      0,
      (sum, item) {
        final ton = (num.tryParse(item['tonnage_available']?.toString() ?? '0') ?? 0).toDouble();
        final price = (num.tryParse(item['price_per_ton']?.toString() ?? '0') ?? 0).toDouble();
        return sum + (ton * price);
      },
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        automaticallyImplyLeading: false,
        titleSpacing: 16,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Katalog Pasokan Hijau',
              style: TextStyle(
                fontSize: 17.5,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
                letterSpacing: -0.3,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Bursa Scrap & Bahan Baku Rendah Emisi',
              style: TextStyle(
                fontSize: 11,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE2E8F0), height: 1),
        ),
        actions: [
          // 1. Tombol Refresh Dinamis (Sangat Rapi & Elegan)
          IconButton(
            icon: _isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0284C7)),
                    ),
                  )
                : const Icon(Icons.refresh_rounded, color: Color(0xFF475569), size: 22),
            tooltip: 'Segarkan Data Supabase',
            onPressed: _isLoading ? null : _fetchSupplies,
          ),

          // 2. Tombol Info Harga Acuan ICDX (Modal Pasar)
          IconButton(
            icon: const Icon(Icons.insights_rounded, color: Color(0xFF475569), size: 22),
            tooltip: 'Acuan Harga Pasar (ICDX)',
            onPressed: _showMarketPriceBenchmarks,
          ),

          // 3. Tombol Tambah Pasokan Cepat
          Padding(
            padding: const EdgeInsets.only(right: 14.0, left: 4.0),
            child: InkWell(
              onTap: _openAddNewSupply,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6.5),
                decoration: BoxDecoration(
                  color: const Color(0xFF0284C7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_rounded, color: Colors.white, size: 16),
                    SizedBox(width: 4),
                    Text(
                      'Pasok',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchSupplies,
        color: const Color(0xFF0284C7),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==============================================================
              // 1. HERO BANNER: KONTRIBUSI EMISI & INVENTARIS PASOKAN
              // ==============================================================
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
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.eco_rounded, color: Colors.white, size: 18),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  _companyName != null && _companyName!.isNotEmpty
                                      ? 'PORTOFOLIO: ${_companyName!.toUpperCase()}'
                                      : 'KONTRIBUSI EMISI SIRKULAR',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.5,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.verified_rounded, color: Colors.white, size: 12),
                              SizedBox(width: 4),
                              Text(
                                'Terverifikasi MRF',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '${NumberFormat('#,##0.0', 'id_ID').format(totalCo2Saved)} tCO2e',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 27,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Total emisi karbon dihemat oleh pabrik baja melalui substitusi scrap & reduktor biomassa Anda.',
                      style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.35),
                    ),
                    const SizedBox(height: 14),
                    const Divider(color: Colors.white24, height: 1),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildHeaderStat('Total Stok Aktif', '${NumberFormat('#,##0', 'id_ID').format(totalStock)} Ton'),
                        Container(width: 1, height: 26, color: Colors.white24),
                        _buildHeaderStat('Estimasi Nilai', currencyCompact.format(totalEstimatedValue)),
                        Container(width: 1, height: 26, color: Colors.white24),
                        _buildHeaderStat('Mitra Pabrik', '142 Pabrik EAF'),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // ==============================================================
              // 2. TICKER RIBBON: HARGA ACUAN PASAR LOGAM SIRKULAR (ICDX)
              // ==============================================================
              InkWell(
                onTap: _showMarketPriceBenchmarks,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(Icons.analytics_outlined, size: 15, color: Color(0xFFD97706)),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Acuan ICDX:',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'HMS-1: Rp 7.100/kg • Shredded: Rp 7.350/kg • PKS: Rp 2.200/kg',
                          style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded, size: 16, color: Color(0xFF94A3B8)),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ==============================================================
              // 3. PENCARIAN REAL-TIME PASOKAN
              // ==============================================================
              Container(
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    const Icon(Icons.search_rounded, color: Color(0xFF64748B), size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _searchCtrl,
                        onChanged: (val) {
                          setState(() {
                            _searchQuery = val.trim().toLowerCase();
                          });
                        },
                        style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
                        decoration: const InputDecoration(
                          hintText: 'Cari nama scrap, depo (Surabaya, Cilegon), grade Fe...',
                          hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 12.5),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    if (_searchQuery.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          _searchCtrl.clear();
                          setState(() => _searchQuery = '');
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Color(0xFFF1F5F9),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close_rounded, size: 14, color: Color(0xFF64748B)),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ==============================================================
              // 4. FILTER KATEGORI BAHAN BAKU
              // ==============================================================
              const Text(
                'Kategori Bahan Baku Sirkular',
                style: TextStyle(
                  fontSize: 13.5,
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
                    final int count = cat == 'Semua Kategori'
                        ? _mySupplyList.length
                        : _mySupplyList.where((i) => i['category'] == cat).length;

                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text('$cat ($count)'),
                        selected: isSelected,
                        onSelected: (val) {
                          setState(() => _selectedCategory = cat);
                        },
                        selectedColor: const Color(0xFF0284C7),
                        backgroundColor: Colors.white,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : const Color(0xFF475569),
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                          fontSize: 11.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isSelected ? const Color(0xFF0284C7) : const Color(0xFFE2E8F0),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 18),

              // ==============================================================
              // 4. DAFTAR KARTU PASOKAN AKTIF (DINAMIS DARI DATABASE)
              // ==============================================================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      _isShowingUserSuppliesOnly
                          ? 'Pasokan Entitas Anda (${filteredList.length})'
                          : 'Daftar Pasokan Bursa (${filteredList.length})',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: _openAddNewSupply,
                    icon: const Icon(Icons.add_rounded, size: 16, color: Color(0xFF0284C7)),
                    label: const Text(
                      'Tambah Pasokan',
                      style: TextStyle(color: Color(0xFF0284C7), fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              if (filteredList.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.inventory_2_outlined, size: 48, color: Color(0xFF94A3B8)),
                      const SizedBox(height: 12),
                      const Text(
                        'Tidak ada pasokan yang cocok',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Coba ubah kata kunci pencarian atau kategori filter Anda.',
                        style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _openAddNewSupply,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0284C7),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: const Text('Buat Pasokan Baru'),
                      ),
                    ],
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredList.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = filteredList[index];
                    final double tonAvailable =
                        (num.tryParse(item['tonnage_available']?.toString() ?? '0') ?? 0).toDouble();
                    final double pricePerTon =
                        (num.tryParse(item['price_per_ton']?.toString() ?? '0') ?? 0).toDouble();
                    final double feGrade = (num.tryParse(item['fe_grade']?.toString() ?? '0') ?? 0).toDouble();
                    final double co2Saved = (num.tryParse(item['co2_saved_ton']?.toString() ?? '0') ?? 0).toDouble();
                    final bool isMrf = item['mrf_certified'] == true || item['mrf_certified'] == 'true';
                    final String statusStr = (item['status'] ?? 'Siap Kirim').toString();

                    Color statusBg = const Color(0xFFF0FDF4);
                    Color statusColor = const Color(0xFF16A34A);
                    if (statusStr.contains('Terbatas')) {
                      statusBg = const Color(0xFFFFFBEB);
                      statusColor = const Color(0xFFD97706);
                    } else if (statusStr.contains('Habis')) {
                      statusBg = const Color(0xFFFEF2F2);
                      statusColor = const Color(0xFFDC2626);
                    }

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
                          // Header Card: Kategori & Status
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Wrap(
                                      spacing: 6,
                                      runSpacing: 4,
                                      crossAxisAlignment: WrapCrossAlignment.center,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF1F5F9),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            item['category'] ?? 'Scrap',
                                            style: const TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF475569),
                                            ),
                                          ),
                                        ),
                                        if (isMrf)
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFDCFCE7),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: const Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(Icons.verified_rounded, size: 11, color: Color(0xFF16A34A)),
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
                                      item['title'] ?? 'Pasokan Tanpa Judul',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF0F172A),
                                        height: 1.3,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: statusBg,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  statusStr,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: statusColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // Lokasi Depo
                          Row(
                            children: [
                              const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF94A3B8)),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  item['depo'] ?? 'Depo Utama',
                                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),
                          const Divider(color: Color(0xFFF1F5F9), height: 1),
                          const SizedBox(height: 12),

                          // Metrik Teknis & Finansial
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Stok Siap Kirim', style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${NumberFormat('#,##0', 'id_ID').format(tonAvailable)} ${item['unit'] ?? 'Ton'}',
                                      style: const TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF0F172A),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              if (feGrade > 0)
                                Expanded(
                                  flex: 4,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      const Text('Kemurnian Fe & Cu', style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Fe $feGrade% • Cu ${item['cu_impurity'] ?? '< 0.05%'}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF0284C7),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              Expanded(
                                flex: 4,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    const Text('Harga / Ton', style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
                                    const SizedBox(height: 2),
                                    Text(
                                      currency.format(pricePerTon),
                                      style: const TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF059669),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),
                          const Divider(color: Color(0xFFF1F5F9), height: 1),
                          const SizedBox(height: 10),

                          // Footer Kartu: Avoided Emission & Tombol Aksi Langsung
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    const Icon(Icons.eco_outlined, size: 13, color: Color(0xFF16A34A)),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        'Pangkas: ${NumberFormat('#,##0.0', 'id_ID').format(co2Saved)} tCO2e',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF16A34A),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Tombol Update Stok
                                  InkWell(
                                    onTap: () => _showUpdateStockDialog(item),
                                    borderRadius: BorderRadius.circular(6),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF1F5F9),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Row(
                                        children: [
                                          Icon(Icons.edit_rounded, size: 12, color: Color(0xFF475569)),
                                          SizedBox(width: 4),
                                          Text('Edit Stok', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),

                                  // Tombol Tawarkan ke Pabrik
                                  InkWell(
                                    onTap: () => _showOfferToMillsDialog(item),
                                    borderRadius: BorderRadius.circular(6),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF0284C7),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Row(
                                        children: [
                                          Icon(Icons.send_rounded, size: 12, color: Colors.white),
                                          SizedBox(width: 4),
                                          Text('Tawarkan', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                                        ],
                                      ),
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
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderStat(String label, String value) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 10),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
