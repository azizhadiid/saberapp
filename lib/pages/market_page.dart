import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MarketPage extends StatefulWidget {
  const MarketPage({super.key});

  @override
  State<MarketPage> createState() => _MarketPageState();
}

class _MarketPageState extends State<MarketPage> {
  String _searchQuery = '';
  String _selectedCategory = 'Semua Kategori';

  final List<String> _categories = [
    'Semua Kategori',
    'Scrap HMS 1&2 (UMKM)',
    'Shredded & MRF Scrap (UMKM)',
    'Koperasi Besi Tua (UMKM)',
    'Bahan Baku Sirkular (UMKM)',
    'Teknologi EAF',
    'Energi Terbarukan',
  ];

  // Katalog kurasi UMKM Scrap Spesifik & Vendor Dekarbonisasi (Menjamin ketersediaan data tiap kategori saat Live Demo Juri)
  final List<Map<String, dynamic>> _curatedUmkmVendors = [
    {
      'name': 'Koperasi UMKM Logam Jaya (MRF Certified)',
      'category': 'Scrap HMS 1&2 (UMKM)',
      'location': 'Surabaya & Sidoarjo, Jawa Timur (Zona Merah Episentrum)',
      'description':
          'Konsorsium 45 lapak pengepul besi tua UMKM Jawa Timur. Menyediakan Heavy Melting Steel (HMS 1&2) potongan konstruksi & pelat tebal yang telah dipilah melalui Material Recovery Facility (MRF) bebas oli, cat, dan tanah.',
      'info_label': 'Kapasitas Pasok & Grade Fe',
      'info_value': '1.500 Ton/Bln • Fe 98.4%',
      'verification_status': true,
      'badge_text': 'UMKM Lolos Standar MRF',
      'icon_name': 'recycling',
      'emission_saving_per_ton': 1.42, // tCO2e dihemat per ton scrap vs bijih besi BF
      'mrf_purity_percent': 98.4,
      'energy_saving_kwh': 620, // kWh dihemat per ton baja
      'price_per_ton_rp': 6800000,
      'umkm_workers_supported': 180,
    },
    {
      'name': 'Sentra Shredded Scrap Cilegon-Banten Mandiri',
      'category': 'Shredded & MRF Scrap (UMKM)',
      'location': 'Cilegon & Serang, Banten (Klaster Hulu Baja)',
      'description':
          'UMKM pengolahan rongsokan bodi otomotif dan mesin industri menggunakan mesin pencacah (shredder) & pemisah magnetik MRF. Menghasilkan shredded scrap kerapatan tinggi untuk umpan langsung tungku Electric Arc Furnace (EAF).',
      'info_label': 'Reduksi Emisi Lebur EAF',
      'info_value': '-58% CO2e • Fe 99.1%',
      'verification_status': true,
      'badge_text': 'High-Grade EAF Feedstock',
      'icon_name': 'precision_manufacturing',
      'emission_saving_per_ton': 1.54,
      'mrf_purity_percent': 99.1,
      'energy_saving_kwh': 685,
      'price_per_ton_rp': 7250000,
      'umkm_workers_supported': 210,
    },
    {
      'name': 'Paguyuban Pengepul Besi Tua Cikarang-Bekasi',
      'category': 'Koperasi Besi Tua (UMKM)',
      'location': 'Bekasi & Karawang, Jawa Barat (Episentrum Manufaktur)',
      'description':
          'Jaringan 60 pengepul besi tua skala mikro-kecil yang mengumpulkan sisa potongan stamping pabrik otomotif (New Prompt Industrial Scrap / Busheling). Sangat bersih, rendah residu tembaga (Cu < 0.1%), siap lebur tanpa slag berlebih.',
      'info_label': 'Kapasitas & Kemurnian',
      'info_value': '2.200 Ton/Bln • Cu < 0.1%',
      'verification_status': true,
      'badge_text': 'Mitra Sirkular UMKM Jabar',
      'icon_name': 'groups',
      'emission_saving_per_ton': 1.48,
      'mrf_purity_percent': 98.8,
      'energy_saving_kwh': 650,
      'price_per_ton_rp': 7100000,
      'umkm_workers_supported': 320,
    },
    {
      'name': 'UD Barokah Scrap & Baler Press Semarang',
      'category': 'Bahan Baku Sirkular (UMKM)',
      'location': 'Semarang & Tegal, Jawa Tengah (Klaster Pengecoran Logam)',
      'description':
          'Unit usaha pengepresan besi tua (baled scrap bundles) hasil pengumpulan masyarakat dan bengkel bubut UMKM Tegal-Semarang. Mendukung substitusi 52% bahan baku scrap untuk menekan ketergantungan impor besi bekas.',
      'info_label': 'Harga & Kapasitas Baler',
      'info_value': '850 Ton/Bln • Pres Hidrolik',
      'verification_status': false,
      'badge_text': 'UMKM Binaan Vokasi',
      'badge_icon': 'eco',
      'icon_name': 'recycling',
      'emission_saving_per_ton': 1.35,
      'mrf_purity_percent': 96.5,
      'energy_saving_kwh': 580,
      'price_per_ton_rp': 6400000,
      'umkm_workers_supported': 140,
    },
    {
      'name': 'PT Krakatau Engineering & EAF Retrofit Tech',
      'category': 'Teknologi EAF',
      'location': 'DKI Jakarta & Cilegon',
      'description':
          'Penyedia layanan konversi tungku Blast Furnace / Induction Furnace menuju Electric Arc Furnace (EAF) hemat energi dilengkapi sistem Off-Gas Heat Recovery, Wet Scrubber (SDG 3), dan integrasi sensor emisi IoT.',
      'info_label': 'Efisiensi Intensitas Karbon',
      'info_value': 'Turun ke 0.42 tCO2/ton',
      'verification_status': true,
      'badge_text': 'Verified Tech Provider',
      'icon_name': 'factory',
      'emission_saving_per_ton': 1.60,
      'mrf_purity_percent': 99.5,
      'energy_saving_kwh': 740,
      'price_per_ton_rp': 12500000,
      'umkm_workers_supported': 95,
    },
    {
      'name': 'Nusantara Solar & Green Hydrogen (H2-DRI) Power',
      'category': 'Energi Terbarukan',
      'location': 'Jawa Timur & Sumatera Selatan',
      'description':
          'Instalasi PLTS Atap Skala Industri (Zero-CAPEX PPA) dan pasokan Biomassa Cangkang Sawit bersertifikat ISPO serta modul elektroliser Hidrogen Hijau untuk dekarbonisasi Scope 2 smelter baja.',
      'info_label': 'Potensi Pangkas Scope 2',
      'info_value': 'Hingga -35% Emisi Listrik',
      'verification_status': true,
      'badge_text': 'Clean Energy Partner',
      'icon_name': 'solar_power',
      'emission_saving_per_ton': 0.85,
      'mrf_purity_percent': 100.0,
      'energy_saving_kwh': 890,
      'price_per_ton_rp': 5500000,
      'umkm_workers_supported': 110,
    },
  ];

  String _selectedSourceType = 'Semua Sumber';
  final List<String> _sourceTypes = [
    'Semua Sumber',
    'Mitra UMKM Scrap',
    'Vendor Perusahaan Hijau',
  ];

  List<Map<String, dynamic>> _allVendors = [];
  List<Map<String, dynamic>> _myOrders = [];
  bool _isLoading = true;

  String? _buyerUserId;
  String? _buyerCompanyId;
  String? _buyerCompanyName;
  String? _buyerLocation;

  @override
  void initState() {
    super.initState();
    _fetchVendors();
  }

  Future<void> _fetchVendors() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        _buyerUserId = user.id;
        try {
          var comp = await Supabase.instance.client
              .from('companies')
              .select('id, name, location')
              .eq('user_id', user.id)
              .maybeSingle();

          if (comp == null && user.email != null && user.email!.isNotEmpty) {
            comp = await Supabase.instance.client
                .from('companies')
                .select('id, name, location')
                .eq('email', user.email!)
                .maybeSingle();
          }

          if (comp != null) {
            _buyerCompanyId = comp['id']?.toString();
            _buyerCompanyName = comp['name']?.toString();
            _buyerLocation = comp['location']?.toString();
          }
        } catch (e) {
          debugPrint('Info query buyer company: $e');
        }
      }
      if (_buyerCompanyName == null || _buyerCompanyName!.isEmpty) {
        final userName = user?.userMetadata?['company_name']?.toString() ??
            user?.userMetadata?['full_name']?.toString() ??
            user?.userMetadata?['name']?.toString() ??
            user?.email?.split('@').first;
        _buyerCompanyName = (userName != null && userName.isNotEmpty)
            ? (userName.toLowerCase().startsWith('pt') ? userName : 'PT $userName')
            : 'Pabrik Baja Mitra';
        _buyerLocation = 'Cilegon, Banten';
      }

      // 1. Ambil pasokan riil secara dinamis dari tabel umkm_supplies
      final List<Map<String, dynamic>> supplyCards = [];
      try {
        final suppliesRes = await Supabase.instance.client
            .from('umkm_supplies')
            .select()
            .order('created_at', ascending: false);

        final dbSupplies = List<Map<String, dynamic>>.from(suppliesRes);
        for (final s in dbSupplies) {
          final double ton = (num.tryParse(s['tonnage_available']?.toString() ?? '0') ?? 0).toDouble();
          final double price = (num.tryParse(s['price_per_ton']?.toString() ?? '0') ?? 6800000).toDouble();
          final double fe = (num.tryParse(s['fe_grade']?.toString() ?? '0') ?? 98.4).toDouble();
          final double co2 = (num.tryParse(s['co2_saved_ton']?.toString() ?? '0') ?? 0).toDouble();
          final double savingFactor = ton > 0 ? (co2 / ton) : 1.42;

          supplyCards.add({
            'id': s['id'],
            'is_supply_item': true,
            'supply_id': s['id'],
            'seller_user_id': s['user_id'],
            'seller_company_id': s['company_id'],
            'seller_name': s['depo'] ?? 'Sentra Pengolahan UMKM',
            'name': s['title'] ?? 'Pasokan Scrap EAF',
            'category': s['category'] ?? 'Scrap HMS 1&2 (UMKM)',
            'source_type': 'umkm',
            'location': s['depo'] ?? 'Depo Pengepul & MRF',
            'description':
                'Pasokan riil sirkular dari depo mitra UMKM. Stok siap kirim: ${ton.toStringAsFixed(0)} ${s['unit'] ?? 'Ton'}, Kemurnian Fe: ${fe.toStringAsFixed(1)}%, Residu Cu: ${s['cu_impurity'] ?? '< 0.05%'}, Status: ${s['status'] ?? 'Siap Kirim'}.',
            'info_label': 'Stok Pasokan & Harga',
            'info_value':
                '${NumberFormat('#,##0', 'id_ID').format(ton)} ${s['unit'] ?? 'Ton'} • Rp ${NumberFormat('#,##0', 'id_ID').format(price)}/Ton',
            'verification_status': s['mrf_certified'] == true,
            'badge_text': s['mrf_certified'] == true
                ? 'UMKM Lolos Standar MRF'
                : 'Pasokan Terverifikasi',
            'badge_icon': 'recycling',
            'icon_name': 'recycling',
            'emission_saving_per_ton': savingFactor > 0 ? savingFactor : 1.42,
            'mrf_purity_percent': fe > 0 ? fe : 98.4,
            'energy_saving_kwh': 620.0,
            'price_per_ton_rp': price,
            'tonnage_available': ton > 0 ? ton : 1000.0,
            'unit': s['unit'] ?? 'Ton',
            'cu_impurity': s['cu_impurity'] ?? '< 0.05%',
            'umkm_workers_supported': (ton * 0.12).round().clamp(20, 500),
          });
        }
      } catch (e) {
        debugPrint('Info query umkm_supplies: $e');
      }

      // 2. Ambil vendor dekarbonisasi dari green_vendor_markets
      final response = await Supabase.instance.client
          .from('green_vendor_markets')
          .select()
          .order('created_at', ascending: false);

      final dbVendors = List<Map<String, dynamic>>.from(response).map((v) {
        return {
          ...v,
          'source_type': 'vendor_hijau',
        };
      }).toList();

      final existingNames = {
        ...supplyCards.map((v) => (v['name'] ?? '').toString().toLowerCase()),
        ...dbVendors.map((v) => (v['name'] ?? '').toString().toLowerCase()),
      };

      final curatedFiltered = _curatedUmkmVendors
          .where((c) => !existingNames.contains(c['name'].toString().toLowerCase()))
          .map((c) => {
                ...c,
                'source_type': c['category'].toString().contains('UMKM') ? 'umkm' : 'vendor_hijau',
              })
          .toList();

      final merged = [
        ...supplyCards,
        ...curatedFiltered,
        ...dbVendors,
      ];

      if (mounted) {
        setState(() {
          _allVendors = merged;
          _isLoading = false;
        });
      }

      // Ambil daftar riwayat pesanan (PO) pembeli
      _fetchBuyerOrders();
    } catch (e) {
      if (mounted) {
        setState(() {
          _allVendors = List<Map<String, dynamic>>.from(_curatedUmkmVendors);
          _isLoading = false;
        });
      }
      debugPrint('Error fetching vendors: $e');
    }
  }

  Future<void> _fetchBuyerOrders() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        if (mounted) {
          setState(() {
            _myOrders = [];
          });
        }
        return;
      }

      var query = Supabase.instance.client
          .from('umkm_orders')
          .select();

      if (_buyerCompanyId != null && _buyerCompanyId!.isNotEmpty) {
        query = query.or('buyer_user_id.eq.${user.id},buyer_company_id.eq.$_buyerCompanyId');
      } else {
        query = query.eq('buyer_user_id', user.id);
      }

      final res = await query.order('created_at', ascending: false);
      final allOrders = List<Map<String, dynamic>>.from(res);
      if (mounted) {
        setState(() {
          _myOrders = allOrders;
        });
      }
    } catch (e) {
      debugPrint('Info fetching buyer orders: $e');
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

  double _getEmissionSavingFactor(Map<String, dynamic> vendor) {
    if (vendor['emission_saving_per_ton'] != null) {
      return (vendor['emission_saving_per_ton'] as num).toDouble();
    }
    final cat = (vendor['category'] ?? '').toString().toLowerCase();
    if (cat.contains('scrap') || cat.contains('umkm') || cat.contains('sirkular')) {
      return 1.42; // Standar penghematan 1 ton scrap di EAF vs bijih besi Blast Furnace
    } else if (cat.contains('eaf') || cat.contains('teknologi')) {
      return 1.55;
    }
    return 0.85;
  }

  double _getMrfPurity(Map<String, dynamic> vendor) {
    if (vendor['mrf_purity_percent'] != null) {
      return (vendor['mrf_purity_percent'] as num).toDouble();
    }
    return 97.8;
  }

  double _getEnergySavingKwh(Map<String, dynamic> vendor) {
    if (vendor['energy_saving_kwh'] != null) {
      return (vendor['energy_saving_kwh'] as num).toDouble();
    }
    return 610;
  }

  int _getWorkersSupported(Map<String, dynamic> vendor) {
    if (vendor['umkm_workers_supported'] != null) {
      return (vendor['umkm_workers_supported'] as num).toInt();
    }
    return 125;
  }

  // ===========================================================================
  // SUBMIT PURCHASE ORDER (PO) KE SUPABASE & BUKA DIALOG SUKSES
  // ===========================================================================
  Future<void> _submitPurchaseOrder({
    required BuildContext modalCtx,
    required Map<String, dynamic> vendor,
    required double volumeTon,
    required double savingPerTon,
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    final unitPrice = (vendor['price_per_ton_rp'] as num?)?.toDouble() ?? 6800000.0;
    final totalPrice = volumeTon * unitPrice;
    final totalCo2Reduced = volumeTon * savingPerTon;
    final orderNo = 'PO-BAJA-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}';

    final user = Supabase.instance.client.auth.currentUser;
    final buyerUid = _buyerUserId ?? user?.id;

    String buyerName = _buyerCompanyName ?? 'Pabrik Baja Mitra';
    final userFullName = user?.userMetadata?['company_name']?.toString() ??
        user?.userMetadata?['full_name']?.toString() ??
        user?.userMetadata?['name']?.toString();
    if (userFullName != null && userFullName.isNotEmpty && (buyerName == 'Pabrik Baja Mitra' || buyerName == 'PT DITRA')) {
      buyerName = userFullName.toLowerCase().startsWith('pt') ? userFullName : 'PT $userFullName';
    }

    try {
      final newOrder = <String, dynamic>{
        'order_number': orderNo,
        'buyer_user_id': buyerUid,
        'buyer_company_id': _buyerCompanyId,
        'buyer_name': buyerName,
        'buyer_location': _buyerLocation ?? 'Cilegon, Banten',
        'seller_user_id': vendor['seller_user_id']?.toString(),
        'seller_company_id': vendor['seller_company_id']?.toString(),
        'seller_name': vendor['seller_name'] ?? vendor['name'] ?? 'Mitra UMKM Scrap',
        'supply_id': vendor['supply_id']?.toString(),
        'item_title': vendor['name'] ?? 'Pasokan Scrap EAF',
        'category': vendor['category'] ?? 'Scrap HMS 1&2',
        'order_volume_tons': volumeTon,
        'price_per_ton': unitPrice,
        'total_price': totalPrice,
        'estimated_co2_saved': totalCo2Reduced,
        'status': 'Menunggu Konfirmasi',
        'delivery_address': 'Pabrik Peleburan EAF Baja Cilegon - Dermaga & Gudang Logistik Scrap',
        'notes': 'Purchase Order pasokan bahan baku sirkular untuk pemenuhan target 52% scrap EAF.',
      };

      await Supabase.instance.client.from('umkm_orders').insert(newOrder);
      await _fetchBuyerOrders();

      if (!modalCtx.mounted) return;
      Navigator.pop(modalCtx);

      if (!mounted) return;
      _showOrderSuccessDialog(
        orderNo: orderNo,
        itemTitle: vendor['name'] ?? 'Pasokan Scrap EAF',
        sellerName: vendor['seller_name'] ?? vendor['name'] ?? 'Mitra Pemasok UMKM',
        volumeTon: volumeTon,
        totalPrice: totalPrice,
        co2Saved: totalCo2Reduced,
      );
    } catch (e) {
      debugPrint('Error submit order: $e');
      messenger.showSnackBar(
        SnackBar(
          content: Text('Gagal menerbitkan Purchase Order: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showOrderSuccessDialog({
    required String orderNo,
    required String itemTitle,
    required String sellerName,
    required double volumeTon,
    required double totalPrice,
    required double co2Saved,
  }) {
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final numberFormatter = NumberFormat.decimalPattern('id_ID');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: Color(0xFFECFDF5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded, color: Color(0xFF059669), size: 36),
              ),
              const SizedBox(height: 14),
              const Text(
                'PO Berhasil Diterbitkan!',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                'No. PO: $orderNo',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF059669)),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    _buildDialogReceiptRow('Item Pasokan:', itemTitle),
                    const SizedBox(height: 6),
                    _buildDialogReceiptRow('Mitra Pemasok:', sellerName),
                    const SizedBox(height: 6),
                    _buildDialogReceiptRow('Volume Pasokan:', '${numberFormatter.format(volumeTon.round())} Ton'),
                    const SizedBox(height: 6),
                    _buildDialogReceiptRow('Total Nilai PO:', currencyFormatter.format(totalPrice)),
                    const SizedBox(height: 6),
                    _buildDialogReceiptRow('Potensi Reduksi:', '-${numberFormatter.format(co2Saved.round())} tCO2e'),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Pesanan telah terkirim otomatis ke portal UMKM di menu Permintaan untuk diverifikasi dan diterbitkan Surat Jalan (DO).',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: Color(0xFF64748B), height: 1.35),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup', style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              _showBuyerOrderHistorySheet();
            },
            icon: const Icon(Icons.shopping_basket_outlined, size: 16),
            label: const Text('Buka Keranjang PO', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF059669),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogReceiptRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // KERANJANG & RIWAYAT PESANAN (PO) PEMBELI PABRIK BAJA
  // ===========================================================================
  void _showBuyerOrderHistorySheet() {
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final numberFormatter = NumberFormat.decimalPattern('id_ID');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final double totalPoValue = _myOrders.fold<double>(
              0,
              (sum, o) => sum + (num.tryParse(o['total_price']?.toString() ?? '0') ?? 0).toDouble(),
            );
            final double totalTonnage = _myOrders.fold<double>(
              0,
              (sum, o) => sum + (num.tryParse(o['order_volume_tons']?.toString() ?? '0') ?? 0).toDouble(),
            );
            final double totalCo2Saved = _myOrders.fold<double>(
              0,
              (sum, o) => sum + (num.tryParse(o['estimated_co2_saved']?.toString() ?? '0') ?? 0).toDouble(),
            );

            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD1D5DB),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Keranjang & Riwayat PO Pembelian',
                              style: TextStyle(
                                fontSize: 16.5,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Pesanan Pasokan Scrap ke UMKM & Vendor Hijau',
                              style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Hero Summary Mini
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF059669), Color(0xFF047857)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Total Belanja PO', style: TextStyle(fontSize: 10, color: Colors.white70)),
                              const SizedBox(height: 2),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  currencyFormatter.format(totalPoValue),
                                  style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(width: 1, height: 28, color: Colors.white24),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text('Total Pasokan', style: TextStyle(fontSize: 10, color: Colors.white70)),
                              const SizedBox(height: 2),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  '${numberFormatter.format(totalTonnage.round())} Ton',
                                  style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(width: 1, height: 28, color: Colors.white24),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text('Reduksi CO2e', style: TextStyle(fontSize: 10, color: Colors.white70)),
                              const SizedBox(height: 2),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  '-${numberFormatter.format(totalCo2Saved.round())} tCO2e',
                                  style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Daftar Pesanan
                  Expanded(
                    child: _myOrders.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFF1F5F9),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.shopping_basket_outlined,
                                      size: 36,
                                      color: Color(0xFF94A3B8),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'Belum Ada Purchase Order (PO)',
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Pilih bahan baku sirkular scrap dari UMKM di bursa marketplace dan ajukan kontrak pasok untuk menerbitkan PO.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.separated(
                            itemCount: _myOrders.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final order = _myOrders[index];
                              return _buildBuyerOrderCard(order);
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBuyerOrderCard(Map<String, dynamic> order) {
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final numberFormatter = NumberFormat.decimalPattern('id_ID');

    final status = order['status']?.toString() ?? 'Menunggu Konfirmasi';
    final doNum = order['delivery_order_number']?.toString();
    final rejectReason = order['rejection_reason']?.toString();

    Color statusColor;
    Color statusBg;
    IconData statusIcon;

    switch (status) {
      case 'Diproses':
        statusColor = const Color(0xFF0284C7);
        statusBg = const Color(0xFFE0F2FE);
        statusIcon = Icons.hourglass_top_rounded;
        break;
      case 'Dalam Pengiriman':
        statusColor = const Color(0xFF4F46E5);
        statusBg = const Color(0xFFEEF2FF);
        statusIcon = Icons.local_shipping_outlined;
        break;
      case 'Selesai':
        statusColor = const Color(0xFF16A34A);
        statusBg = const Color(0xFFDCFCE7);
        statusIcon = Icons.check_circle_outline_rounded;
        break;
      case 'Ditolak':
        statusColor = const Color(0xFFDC2626);
        statusBg = const Color(0xFFFEE2E2);
        statusIcon = Icons.cancel_outlined;
        break;
      default:
        statusColor = const Color(0xFFD97706);
        statusBg = const Color(0xFFFEF3C7);
        statusIcon = Icons.schedule_rounded;
    }

    final double vol = (num.tryParse(order['order_volume_tons']?.toString() ?? '0') ?? 0).toDouble();
    final double price = (num.tryParse(order['total_price']?.toString() ?? '0') ?? 0).toDouble();
    final double co2 = (num.tryParse(order['estimated_co2_saved']?.toString() ?? '0') ?? 0).toDouble();

    return Container(
      padding: const EdgeInsets.all(12),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  order['order_number'] ?? 'PO-BAJA',
                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF059669)),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, size: 11, color: statusColor),
                    const SizedBox(width: 4),
                    Text(
                      status,
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            order['item_title'] ?? 'Pasokan Scrap EAF',
            style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            'Mitra Pemasok: ${order['seller_name'] ?? 'Pengepul / Depo UMKM'}',
            style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Volume Pasok', style: TextStyle(fontSize: 9.5, color: Color(0xFF64748B))),
                      Text(
                        '${numberFormatter.format(vol.round())} Ton',
                        style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text('Total Nilai PO', style: TextStyle(fontSize: 9.5, color: Color(0xFF64748B))),
                      Text(
                        currencyFormatter.format(price),
                        style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF059669)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('Reduksi Emisi', style: TextStyle(fontSize: 9.5, color: Color(0xFF64748B))),
                      Text(
                        '-${numberFormatter.format(co2.round())} tCO2e',
                        style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF16A34A)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (doNum != null && doNum.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFC7D2FE)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.local_shipping_rounded, size: 14, color: Color(0xFF4F46E5)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Surat Jalan / DO: $doNum (Dalam Perjalanan Logistik)',
                      style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5)),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (rejectReason != null && rejectReason.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFECACA)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, size: 14, color: Color(0xFFDC2626)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Alasan Ditolak: $rejectReason',
                      style: const TextStyle(fontSize: 10.5, color: Color(0xFFDC2626)),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ===========================================================================
  // MODAL SIMULASI ESTIMASI DAMPAK EMISI, MRF & PENGHEMATAN PAJAK CBAM (LANGKAH 3)
  // ===========================================================================
  void _showEmissionImpactSheet(Map<String, dynamic> vendor) {
    double volumeTon = 500.0; // Default simulasi 500 ton pasokan scrap/kapasitas
    final double savingPerTon = _getEmissionSavingFactor(vendor);
    final double mrfPurity = _getMrfPurity(vendor);
    final double kwhPerTon = _getEnergySavingKwh(vendor);
    final int baseWorkers = _getWorkersSupported(vendor);
    final String title = vendor['name'] ?? 'Mitra UMKM / Vendor Hijau';
    final String category = vendor['category'] ?? 'Bahan Baku Sirkular (UMKM)';
    final double unitPrice = (vendor['price_per_ton_rp'] as num?)?.toDouble() ?? 6800000.0;

    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final numberFormatter = NumberFormat.decimalPattern('id_ID');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final double totalCo2Reduced = volumeTon * savingPerTon;
            final double cleanScrapOutput = volumeTon * (mrfPurity / 100.0);
            final double totalMwhSaved = (volumeTon * kwhPerTon) / 1000.0;
            final double totalPrice = volumeTon * unitPrice;
            // Asumsi tarif denda CBAM EU €60 (~Rp 1.050.000 / ton CO2e)
            final double cbamPenaltySavedRp = totalCo2Reduced * 1050000;
            // Pajak karbon domestik UU HPP No. 7/2021 (Rp 30.000 / ton CO2e)
            final double domesticTaxSavedRp = totalCo2Reduced * 30000;
            // Kontribusi terhadap target 52% Scrap EAF (misal kebutuhan bulanan pabrik 2.500 ton)
            final double eafScrapTargetCoverage =
                ((volumeTon / 2500.0) * 52.0).clamp(0.0, 100.0);
            final int impactedWorkers =
                (baseWorkers * (volumeTon / 500.0)).round().clamp(15, 2500);

            return Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 44,
                        height: 5,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD1D5DB),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.co2_rounded,
                            color: Color(0xFF059669),
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'KALKULATOR DAMPAK EMISI & SIRKULARITAS MRF',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF059669),
                                  letterSpacing: 0.7,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF111827),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                category,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),

                    // Slider Volume Pengadaan Scrap / Kapasitas
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Text(
                            'Simulasi Volume Pasokan / Kontrak:',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF374151),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF065F46),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${numberFormatter.format(volumeTon.round())} Ton',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: const Color(0xFF10B981),
                        inactiveTrackColor: const Color(0xFFD1FAE5),
                        thumbColor: const Color(0xFF059669),
                      ),
                      child: Slider(
                        value: volumeTon,
                        min: 50,
                        max: 5000,
                        divisions: 99,
                        label: '${volumeTon.round()} Ton',
                        onChanged: (val) {
                          setModalState(() => volumeTon = val);
                        },
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Grid 4 Metrik Utama Dampak Emisi & MRF
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFA7F3D0)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildImpactMetricTile(
                                  label: 'REDUKSI EMISI GRK',
                                  value:
                                      '-${numberFormatter.format(totalCo2Reduced.round())} tCO2e',
                                  sub:
                                      '(-${savingPerTon.toStringAsFixed(2)} tCO2e/ton vs BF)',
                                  icon: Icons.cloud_off_rounded,
                                  color: const Color(0xFF059669),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildImpactMetricTile(
                                  label: 'OUTPUT BERSIH MRF',
                                  value:
                                      '${numberFormatter.format(cleanScrapOutput.round())} Ton',
                                  sub:
                                      'Kemurnian Fe ${mrfPurity.toStringAsFixed(1)}%',
                                  icon: Icons.filter_alt_outlined,
                                  color: const Color(0xFF0284C7),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: _buildImpactMetricTile(
                                  label: 'PENGHEMATAN ENERGI',
                                  value:
                                      '${numberFormatter.format(totalMwhSaved.round())} MWh',
                                  sub: 'Listrik Tungku EAF',
                                  icon: Icons.bolt_rounded,
                                  color: const Color(0xFFD97706),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildImpactMetricTile(
                                  label: 'DAMPAK SOSIAL UMKM',
                                  value: '$impactedWorkers Pekerja',
                                  sub: 'Pengepul & Sortir MRF',
                                  icon: Icons.groups_rounded,
                                  color: const Color(0xFF4F46E5),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Kotak Valuasi Penghematan Pajak CBAM & UU HPP
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'VALUASI FINANSIAL & KEPATUHAN REGULASI:',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF475569),
                              letterSpacing: 0.6,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Expanded(
                                child: Text(
                                  'Potensi Denda EU CBAM Dihemat:',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF334155),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  currencyFormatter.format(cbamPenaltySavedRp),
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF059669),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Expanded(
                                child: Text(
                                  'Pajak Karbon Domestik (UU HPP):',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF334155),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  'Hemat ${currencyFormatter.format(domesticTaxSavedRp)}',
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF0F172A),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Expanded(
                                child: Text(
                                  'Kontribusi ke Target 52% Scrap EAF:',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF334155),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  '${eafScrapTargetCoverage.toStringAsFixed(1)}% Terpenuhi',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0284C7),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Ringkasan Nilai Transaksi Purchase Order (PO)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFA7F3D0)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'ESTIMASI NILAI PURCHASE ORDER (PO):',
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF065F46),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Harga: ${currencyFormatter.format(unitPrice)} / Ton',
                                  style: const TextStyle(fontSize: 11, color: Color(0xFF047857)),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              currencyFormatter.format(totalPrice),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF059669),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Tombol Aksi Penerbitan Purchase Order (PO)
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _submitPurchaseOrder(
                            modalCtx: context,
                            vendor: vendor,
                            volumeTon: volumeTon,
                            savingPerTon: savingPerTon,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF059669),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: const Icon(Icons.shopping_cart_checkout_rounded, size: 18),
                        label: const FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'Konfirmasi & Terbitkan Purchase Order (PO)',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildImpactMetricTile({
    required String label,
    required String value,
    required String sub,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6B7280),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            sub,
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF4B5563),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Filter logic pintar (mendukung filter Sumber: UMKM vs Vendor Hijau & Sub-kategori Scrap)
    final filteredVendors = _allVendors.where((vendor) {
      final nameStr = (vendor['name'] ?? '').toString().toLowerCase();
      final descStr = (vendor['description'] ?? '').toString().toLowerCase();
      final catStr = (vendor['category'] ?? '').toString();

      final matchesSearch =
          nameStr.contains(_searchQuery.toLowerCase()) ||
          descStr.contains(_searchQuery.toLowerCase()) ||
          catStr.toLowerCase().contains(_searchQuery.toLowerCase());

      bool matchesCategory = false;
      if (_selectedCategory == 'Semua Kategori') {
        matchesCategory = true;
      } else if (_selectedCategory == 'Bahan Baku Sirkular (UMKM)') {
        matchesCategory = catStr.contains('UMKM') || catStr.contains('Scrap');
      } else {
        matchesCategory = catStr == _selectedCategory;
      }

      bool matchesSource = true;
      if (_selectedSourceType == 'Mitra UMKM Scrap') {
        matchesSource = (vendor['source_type'] == 'umkm') ||
            catStr.contains('UMKM') ||
            catStr.contains('Scrap');
      } else if (_selectedSourceType == 'Vendor Perusahaan Hijau') {
        matchesSource = (vendor['source_type'] == 'vendor_hijau') ||
            (!catStr.contains('UMKM') && !catStr.contains('Scrap'));
      }

      return matchesSearch && matchesCategory && matchesSource;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
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
              'Bursa Scrap UMKM (MRF) & Teknologi Hijau',
              style: TextStyle(color: Color(0xFF6B7280), fontSize: 11),
            ),
          ],
        ),
        actions: [
          Badge(
            isLabelVisible: _myOrders.isNotEmpty,
            label: Text(
              '${_myOrders.length}',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            backgroundColor: const Color(0xFF059669),
            alignment: const AlignmentDirectional(20, -10),
            child: IconButton(
              icon: const Icon(
                Icons.shopping_basket_outlined,
                color: Color(0xFF4B5563),
              ),
              tooltip: 'Keranjang & Riwayat PO Pembelian',
              onPressed: _showBuyerOrderHistorySheet,
            ),
          ),
          const SizedBox(width: 8),
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
                      'Green Marketplace & Bursa Scrap UMKM',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Integrasi Rantai Pasok 52% Scrap EAF (Standar MRF) & Teknologi Dekarbonisasi',
                      style: TextStyle(fontSize: 13, color: Color(0xFF4B5563)),
                    ),
                    const SizedBox(height: 14),

                    // Banner Ringkas MRF & Ekonomi Sirkular UMKM
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFA7F3D0)),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.recycling_rounded,
                            color: Color(0xFF059669),
                            size: 22,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Setiap 1 ton High-Grade Scrap UMKM (lolos sortir MRF) di tungku EAF memangkas ~1,42 ton CO2e dibanding bijih besi Blast Furnace.',
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFF065F46),
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

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
                                    'Cari Scrap HMS 1&2, Shredded MRF, Koperasi UMKM, EAF...',
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

                    // Segmented Filter Sumber Transaksi: UMKM vs Perusahaan Hijau
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _sourceTypes.map((source) {
                          final bool isSelected = _selectedSourceType == source;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: InkWell(
                              onTap: () {
                                setState(() => _selectedSourceType = source);
                              },
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFF059669)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFF059669)
                                        : const Color(0xFFE2E8F0),
                                    width: 1.2,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      source.contains('UMKM')
                                          ? Icons.recycling_rounded
                                          : (source.contains('Hijau')
                                              ? Icons.eco_rounded
                                              : Icons.hub_rounded),
                                      size: 14,
                                      color: isSelected
                                          ? Colors.white
                                          : const Color(0xFF059669),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      source,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.w600,
                                        color: isSelected
                                            ? Colors.white
                                            : const Color(0xFF334155),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Categories (Termasuk Kategori UMKM Scrap Spesifik)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _categories.map((cat) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: _buildCategoryChip(cat),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Vendor Cards
                    if (filteredVendors.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: Text(
                            'Tidak ada vendor UMKM atau penyedia teknologi yang sesuai dengan pencarian Anda.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Color(0xFF6B7280)),
                          ),
                        ),
                      )
                    else
                      ...filteredVendors.map((vendor) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _buildVendorCard(vendor: vendor),
                        );
                      }),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildCategoryChip(String label) {
    bool isSelected = _selectedCategory == label;
    final bool isUmkmCategory = label.contains('UMKM') || label.contains('Scrap');
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected
              ? (isUmkmCategory
                    ? const Color(0xFF059669)
                    : const Color(0xFF1F2937))
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? null
              : Border.all(
                  color: isUmkmCategory
                      ? const Color(0xFF6EE7B7)
                      : const Color(0xFFE5E7EB),
                ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isUmkmCategory) ...[
              Icon(
                Icons.recycling,
                size: 14,
                color: isSelected ? Colors.white : const Color(0xFF059669),
              ),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : (isUmkmCategory
                          ? const Color(0xFF065F46)
                          : const Color(0xFF6B7280)),
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVendorCard({required Map<String, dynamic> vendor}) {
    final IconData icon = _getIconData(vendor['icon_name']);
    final bool isVerified = vendor['verification_status'] ?? false;
    final String title = vendor['name'] ?? 'Vendor';
    final String category = vendor['category'] ?? 'Bahan Baku Sirkular (UMKM)';
    final String location = vendor['location'] ?? 'Lokasi tidak diketahui';
    final String desc = vendor['description'] ?? '';
    final String infoLabel = vendor['info_label'] ?? 'Info';
    final String infoValue = vendor['info_value'] ?? '-';
    final String? badgeText = vendor['badge_text'];
    final IconData badgeIcon = _getIconData(vendor['badge_icon']);
    final double savingPerTon = _getEmissionSavingFactor(vendor);
    final double mrfPurity = _getMrfPurity(vendor);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: category.contains('UMKM')
              ? const Color(0xFFD1FAE5)
              : const Color(0xFFF3F4F6),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
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
                  color: category.contains('UMKM')
                      ? const Color(0xFFECFDF5)
                      : const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: category.contains('UMKM')
                      ? const Color(0xFF059669)
                      : const Color(0xFF4F46E5),
                  size: 24,
                ),
              ),
              Flexible(
                child: Container(
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
                        isVerified ? Icons.verified : badgeIcon,
                        color: isVerified
                            ? const Color(0xFF10B981)
                            : const Color(0xFF6B7280),
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          badgeText ?? 'Verified Vendor',
                          style: TextStyle(
                            color: isVerified
                                ? const Color(0xFF065F46)
                                : const Color(0xFF4B5563),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Tag Kategori Spesifik
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              category,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Color(0xFF374151),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Title & Location
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
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
              Expanded(
                child: Text(
                  location,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF4B5563),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Description
          Text(
            desc,
            style: const TextStyle(
              fontSize: 13.5,
              color: Color(0xFF4B5563),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),

          // Strip Info Reduksi Emisi & Kemurnian MRF
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFA7F3D0)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.eco_outlined,
                  size: 15,
                  color: Color(0xFF059669),
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    'Reduksi: -${savingPerTon.toStringAsFixed(2)} tCO2e/ton',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF065F46),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'MRF: ${mrfPurity.toStringAsFixed(1)}%',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF047857),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Divider
          const Divider(color: Color(0xFFE5E7EB)),
          const SizedBox(height: 8),

          // Info Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  infoLabel,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  infoValue,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF10B981),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 2 Tombol Aksi: (1) Estimasi Dampak Emisi & (2) Hubungi / Ajukan Kontrak
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _showEmissionImpactSheet(vendor),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF059669),
                    side: const BorderSide(
                      color: Color(0xFF059669),
                      width: 1.3,
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.analytics_outlined, size: 16),
                        SizedBox(width: 5),
                        Text(
                          'Estimasi Dampak Emisi',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 11.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _showEmissionImpactSheet(vendor),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF059669),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.shopping_bag_outlined, size: 16),
                        const SizedBox(width: 5),
                        Text(
                          isVerified ? 'Pesan / Ajukan PO' : 'Ajukan Kontrak PO',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 11.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
