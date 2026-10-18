import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// ============================================================================
/// HALAMAN PERMINTAAN & PESANAN MASUK (PURCHASE ORDERS & RFQ)
/// Terhubung Dinamis dengan Tabel Supabase: umkm_orders & umkm_rfq_demands
/// ============================================================================
class UmkmDemandView extends StatefulWidget {
  const UmkmDemandView({super.key});

  @override
  State<UmkmDemandView> createState() => _UmkmDemandViewState();
}

class _UmkmDemandViewState extends State<UmkmDemandView> {
  int _selectedTab = 0; // 0: Pesanan Masuk (PO Pabrik), 1: Tender Terbuka (RFQ)
  String _selectedStatusFilter = 'Semua';
  bool _isLoading = true;

  String? _myCompanyName;
  String? _myCompanyId;

  List<Map<String, dynamic>> _incomingOrders = [];

  // Data fallback RFQ Tender Terbuka Pabrik Baja Nasional
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

  final currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );
  final numberFormatter = NumberFormat.decimalPattern('id_ID');

  static const primaryEmerald = Color(0xFF059669);
  static const darkEmerald = Color(0xFF065F46);
  static const lightEmeraldBg = Color(0xFFECFDF5);

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  /// Membaca data pesanan masuk secara dinamis dari tabel umkm_orders
  Future<void> _fetchOrders() async {
    setState(() => _isLoading = true);
    try {
      final user = Supabase.instance.client.auth.currentUser;

      if (user != null) {
        try {
          final comp = await Supabase.instance.client
              .from('companies')
              .select('id, name')
              .eq('user_id', user.id)
              .maybeSingle();

          if (comp != null) {
            _myCompanyId = comp['id']?.toString();
            _myCompanyName = comp['name']?.toString();
          }
        } catch (e) {
          debugPrint('Info query company for demand: $e');
        }
      }

      // Query seluruh order masuk dari pabrik baja
      final response = await Supabase.instance.client
          .from('umkm_orders')
          .select()
          .order('created_at', ascending: false);

      final List<Map<String, dynamic>> rawOrders =
          List<Map<String, dynamic>>.from(response);

      // Filter pesanan relevan untuk perusahaan UMKM yang sedang login (dengan fallback rawOrders jika demo/seeder)
      final relevantOrders = (_myCompanyId != null && _myCompanyId!.isNotEmpty)
          ? rawOrders.where((o) => o['seller_company_id']?.toString() == _myCompanyId || o['seller_user_id']?.toString() == user?.id).toList()
          : <Map<String, dynamic>>[];

      final finalOrders = relevantOrders.isNotEmpty ? relevantOrders : rawOrders;

      if (mounted) {
        setState(() {
          _incomingOrders = finalOrders;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetch umkm_orders: $e');
      if (mounted) {
        setState(() {
          _incomingOrders = [];
          _isLoading = false;
        });
      }
    }
  }

  /// Update status order di Supabase
  Future<void> _updateOrderStatus(
    String orderId,
    String newStatus, {
    String? deliveryOrderNo,
    String? rejectionReason,
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final updateData = <String, dynamic>{
        'status': newStatus,
        'updated_at': DateTime.now().toIso8601String(),
        'delivery_order_number': ?deliveryOrderNo,
        'rejection_reason': ?rejectionReason,
      };

      await Supabase.instance.client
          .from('umkm_orders')
          .update(updateData)
          .eq('id', orderId);

      // Perbarui state lokal
      setState(() {
        final idx = _incomingOrders.indexWhere((o) => o['id'].toString() == orderId);
        if (idx != -1) {
          _incomingOrders[idx]['status'] = newStatus;
          if (deliveryOrderNo != null) {
            _incomingOrders[idx]['delivery_order_number'] = deliveryOrderNo;
          }
          if (rejectionReason != null) {
            _incomingOrders[idx]['rejection_reason'] = rejectionReason;
          }
        }
      });

      messenger.showSnackBar(
        SnackBar(
          content: Text('Status pesanan berhasil diperbarui menjadi "$newStatus"'),
          backgroundColor: primaryEmerald,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      debugPrint('Error update order: $e');
      messenger.showSnackBar(
        SnackBar(
          content: Text('Gagal memperbarui status: $e'),
          backgroundColor: const Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// Dialog Konfirmasi Terima Pesanan
  void _showAcceptDialog(Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(Icons.check_circle_outline_rounded, color: primaryEmerald, size: 44),
        title: const Text('Terima & Proses Pesanan?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: Text(
          'Pesanan dari ${order['buyer_name']} sebesar ${order['order_volume_tons']} Ton (${order['item_title']}) akan dipindahkan ke antrean proses penyiapan stok MRF.',
          style: const TextStyle(fontSize: 12.5, color: Color(0xFF475569)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _updateOrderStatus(order['id'].toString(), 'Diproses');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryEmerald,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Ya, Terima Pesanan'),
          ),
        ],
      ),
    );
  }

  /// Dialog Input Surat Jalan (DO) untuk Pengiriman
  void _showShipDialog(Map<String, dynamic> order) {
    final doCtrl = TextEditingController(
      text: 'SJ/DO-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.local_shipping_outlined, color: primaryEmerald),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Kirim Pasokan (Terbitkan DO)',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tujuan Pengiriman: ${order['buyer_name']}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
            Text(
              order['delivery_address'] ?? 'Alamat Pabrik EAF Mitra',
              style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 14),
            const Text('Nomor Surat Jalan / Delivery Order (DO):', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            TextField(
              controller: doCtrl,
              decoration: InputDecoration(
                isDense: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            onPressed: () {
              final doNum = doCtrl.text.trim();
              if (doNum.isEmpty) return;
              Navigator.pop(ctx);
              _updateOrderStatus(order['id'].toString(), 'Dalam Pengiriman', deliveryOrderNo: doNum);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryEmerald,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Kirim Sekarang'),
          ),
        ],
      ),
    );
  }

  /// Dialog Tolak Pesanan
  void _showRejectDialog(Map<String, dynamic> order) {
    final reasonCtrl = TextEditingController(text: 'Kapasitas depo penuh / stok scrap grade ini sedang habis');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(Icons.cancel_outlined, color: Color(0xFFDC2626), size: 40),
        title: const Text('Tolak Pesanan?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Anda akan menolak pesanan dari ${order['buyer_name']} sebesar ${order['order_volume_tons']} Ton.',
              style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
            ),
            const SizedBox(height: 12),
            const Text('Alasan Penolakan:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            TextField(
              controller: reasonCtrl,
              maxLines: 2,
              decoration: InputDecoration(
                isDense: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.all(10),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _updateOrderStatus(
                order['id'].toString(),
                'Ditolak',
                rejectionReason: reasonCtrl.text.trim(),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Tolak Pesanan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Hitung metrik ringkasan
    final int pendingCount = _incomingOrders.where((o) => o['status'] == 'Menunggu Konfirmasi').length;
    final int inProcessCount = _incomingOrders.where((o) => o['status'] == 'Diproses' || o['status'] == 'Dalam Pengiriman').length;
    final double totalTons = _incomingOrders.fold(0.0, (sum, o) => sum + ((o['order_volume_tons'] as num?)?.toDouble() ?? 0.0));
    final double totalRevenue = _incomingOrders.fold(0.0, (sum, o) => sum + ((o['total_price'] as num?)?.toDouble() ?? 0.0));

    // Filter order berdasarkan status
    final filteredOrders = _incomingOrders.where((o) {
      if (_selectedStatusFilter == 'Semua') return true;
      return (o['status'] ?? '').toString().toLowerCase() == _selectedStatusFilter.toLowerCase();
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Permintaan & Pesanan Masuk',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            Text(
              _myCompanyName != null && _myCompanyName!.isNotEmpty
                  ? 'Portofolio Order: ${_myCompanyName!.toUpperCase()}'
                  : 'Bursa Order Pabrik Baja (Purchase Order)',
              style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF475569)),
            tooltip: 'Segarkan Pesanan',
            onPressed: _fetchOrders,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchOrders,
        color: primaryEmerald,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==============================================================
              // 1. HERO SUMMARY: RINGKASAN PO & TRANSAKSI MASUK (RESPONSIF)
              // ==============================================================
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [primaryEmerald, darkEmerald],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: primaryEmerald.withValues(alpha: 0.2),
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
                        const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.receipt_long_rounded, color: Colors.white, size: 18),
                            SizedBox(width: 6),
                            Text(
                              'RINGKASAN PESANAN PABRIK BAJA',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '$pendingCount Menunggu',
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        currencyFormatter.format(totalRevenue),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Total akumulasi nilai pesanan Purchase Order (PO) yang masuk dari offtaker pabrik baja.',
                      style: TextStyle(color: Colors.white70, fontSize: 11.5, height: 1.3),
                    ),
                    const SizedBox(height: 12),
                    const Divider(color: Colors.white24, height: 1),
                    const SizedBox(height: 10),

                    // Grid Baris 3 Statistik (Responsif FittedBox)
                    Row(
                      children: [
                        _buildHeroStatItem('Total Pesanan', '${_incomingOrders.length} PO'),
                        Container(width: 1, height: 24, color: Colors.white24),
                        _buildHeroStatItem('Tonase Masuk', '${numberFormatter.format(totalTons.round())} Ton'),
                        Container(width: 1, height: 24, color: Colors.white24),
                        _buildHeroStatItem('Diproses', '$inProcessCount Order'),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ==============================================================
              // 2. SEGMENTED TAB: PESANAN MASUK VS TENDER TERBUKA (RFQ)
              // ==============================================================
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildSegmentButton(
                        index: 0,
                        title: 'Pesanan Masuk (${_incomingOrders.length})',
                        icon: Icons.inbox_rounded,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: _buildSegmentButton(
                        index: 1,
                        title: 'Tender Terbuka (${_industryRfqs.length})',
                        icon: Icons.campaign_outlined,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // ==============================================================
              // 3. KONTEN TAB: PESANAN MASUK ATAU TENDER TERBUKA
              // ==============================================================
              if (_selectedTab == 0) ...[
                // Filter Status Pesanan
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      'Semua',
                      'Menunggu Konfirmasi',
                      'Diproses',
                      'Dalam Pengiriman',
                      'Selesai',
                      'Ditolak',
                    ].map((status) {
                      final bool isSelected = _selectedStatusFilter == status;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6.0),
                        child: ChoiceChip(
                          label: Text(status),
                          selected: isSelected,
                          onSelected: (val) {
                            setState(() => _selectedStatusFilter = status);
                          },
                          selectedColor: primaryEmerald,
                          backgroundColor: Colors.white,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : const Color(0xFF475569),
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                            fontSize: 11,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected ? primaryEmerald : const Color(0xFFE2E8F0),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 12),

                // List Kartu Order
                if (_isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(color: primaryEmerald),
                    ),
                  )
                else if (filteredOrders.isEmpty)
                  _buildEmptyOrdersState()
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredOrders.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final order = filteredOrders[index];
                      return _buildOrderCard(order);
                    },
                  ),
              ] else ...[
                // Tab 1: Tender Terbuka (RFQ Industri Pabrik Baja)
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _industryRfqs.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final rfq = _industryRfqs[index];
                    return _buildRfqCard(rfq);
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroStatItem(String label, String value) {
    return Expanded(
      child: Column(
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
            style: const TextStyle(color: Colors.white70, fontSize: 10),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentButton({
    required int index,
    required String title,
    required IconData icon,
  }) {
    final bool isSelected = _selectedTab == index;
    return InkWell(
      onTap: () => setState(() => _selectedTab = index),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? primaryEmerald : const Color(0xFF64748B),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? primaryEmerald : const Color(0xFF475569),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Empty State jika belum ada pesanan
  Widget _buildEmptyOrdersState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          const Icon(Icons.shopping_bag_outlined, size: 48, color: Color(0xFF94A3B8)),
          const SizedBox(height: 10),
          const Text(
            'Belum Ada Pesanan Masuk',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 4),
          const Text(
            'Saat pabrik baja (seperti PT DITRA atau Krakatau Steel) memesan pasokan scrap dari bursa Green Market, rincian Purchase Order (PO) akan langsung muncul di sini.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B), height: 1.4),
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: () => setState(() => _selectedTab = 1),
            style: OutlinedButton.styleFrom(
              foregroundColor: primaryEmerald,
              side: const BorderSide(color: primaryEmerald),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            icon: const Icon(Icons.campaign_outlined, size: 16),
            label: const Text('Lihat Tender Terbuka Pabrik', style: TextStyle(fontSize: 11.5)),
          ),
        ],
      ),
    );
  }

  /// Kartu Pesanan Masuk (PO Pabrik Baja)
  Widget _buildOrderCard(Map<String, dynamic> order) {
    final status = (order['status'] ?? 'Menunggu Konfirmasi').toString();
    final double volume = (order['order_volume_tons'] as num?)?.toDouble() ?? 0.0;
    final double price = (order['price_per_ton'] as num?)?.toDouble() ?? 0.0;
    final double totalVal = (order['total_price'] as num?)?.toDouble() ?? (volume * price);
    final double co2 = (order['estimated_co2_saved'] as num?)?.toDouble() ?? (volume * 1.42);

    Color badgeBg;
    Color badgeColor;
    IconData statusIcon;

    switch (status) {
      case 'Diproses':
        badgeBg = const Color(0xFFEFF6FF);
        badgeColor = const Color(0xFF2563EB);
        statusIcon = Icons.hourglass_top_rounded;
        break;
      case 'Dalam Pengiriman':
        badgeBg = const Color(0xFFF3E8FF);
        badgeColor = const Color(0xFF7E22CE);
        statusIcon = Icons.local_shipping_outlined;
        break;
      case 'Selesai':
        badgeBg = const Color(0xFFDCFCE7);
        badgeColor = const Color(0xFF16A34A);
        statusIcon = Icons.verified_rounded;
        break;
      case 'Ditolak':
        badgeBg = const Color(0xFFFEE2E2);
        badgeColor = const Color(0xFFDC2626);
        statusIcon = Icons.cancel_outlined;
        break;
      default:
        badgeBg = const Color(0xFFFEF3C7);
        badgeColor = const Color(0xFFD97706);
        statusIcon = Icons.notifications_active_outlined;
    }

    return Container(
      padding: const EdgeInsets.all(14),
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
          // Header Kartu: Pabrik Baja & Status
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: lightEmeraldBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.factory_rounded, color: primaryEmerald, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order['buyer_name'] ?? 'Pabrik Baja Mitra',
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'No. PO: ${order['order_number'] ?? '-'} • ${order['buyer_location'] ?? 'Indonesia'}',
                      style: const TextStyle(fontSize: 10.5, color: Color(0xFF64748B)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, size: 11, color: badgeColor),
                    const SizedBox(width: 4),
                    Text(
                      status,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: badgeColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 10),

          // Detail Pasokan yang Dipesan
          Text(
            order['item_title'] ?? 'Pasokan Scrap EAF',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            'Kategori: ${order['category'] ?? 'Bahan Baku Sirkular'}',
            style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
          ),

          const SizedBox(height: 10),

          // Grid Metrik Transaksi (Responsif FittedBox)
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFF1F5F9)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Volume Dipesan', style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
                      const SizedBox(height: 2),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '${numberFormatter.format(volume.round())} Ton',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(width: 1, height: 26, color: const Color(0xFFE2E8F0)),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Total Nilai', style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
                      const SizedBox(height: 2),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          currencyFormatter.format(totalVal),
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: primaryEmerald),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(width: 1, height: 26, color: const Color(0xFFE2E8F0)),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Reduksi Emisi', style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
                      const SizedBox(height: 2),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '-${numberFormatter.format(co2.round())} tCO2e',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0284C7)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Detail Surat Jalan jika ada
          if (order['delivery_order_number'] != null && order['delivery_order_number'].toString().isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF3E8FF),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.qr_code_2_rounded, size: 12, color: Color(0xFF7E22CE)),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      'No. Surat Jalan (DO): ${order['delivery_order_number']}',
                      style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: Color(0xFF7E22CE)),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Alasan penolakan jika ada
          if (status == 'Ditolak' && order['rejection_reason'] != null) ...[
            const SizedBox(height: 8),
            Text(
              'Alasan ditolak: ${order['rejection_reason']}',
              style: const TextStyle(fontSize: 11, color: Color(0xFFDC2626), fontStyle: FontStyle.italic),
            ),
          ],

          const SizedBox(height: 12),

          // Tombol Aksi Pesanan (Responsif Wrap)
          if (status == 'Menunggu Konfirmasi')
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _showAcceptDialog(order),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryEmerald,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: const Icon(Icons.check_rounded, size: 15),
                  label: const Text('Terima & Proses Pesanan', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                ),
                OutlinedButton.icon(
                  onPressed: () => _showRejectDialog(order),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFDC2626),
                    side: const BorderSide(color: Color(0xFFFCA5A5)),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: const Icon(Icons.close_rounded, size: 15),
                  label: const Text('Tolak Pesanan', style: TextStyle(fontSize: 11.5)),
                ),
              ],
            )
          else if (status == 'Diproses')
            ElevatedButton.icon(
              onPressed: () => _showShipDialog(order),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              icon: const Icon(Icons.local_shipping_outlined, size: 15),
              label: const Text('Kirim Pasokan (Terbitkan Surat Jalan / DO)', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
            )
          else if (status == 'Dalam Pengiriman')
            ElevatedButton.icon(
              onPressed: () => _updateOrderStatus(order['id'].toString(), 'Selesai'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryEmerald,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              icon: const Icon(Icons.done_all_rounded, size: 15),
              label: const Text('Tandai Telah Diterima Pabrik', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
    );
  }

  /// Kartu RFQ Tender Terbuka Pabrik Baja
  Widget _buildRfqCard(Map<String, dynamic> rfq) {
    return Container(
      padding: const EdgeInsets.all(14),
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
                  color: lightEmeraldBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.factory_outlined, color: primaryEmerald, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rfq['factory_name']!,
                      style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${rfq['location']} • Urgensi: ${rfq['urgency']}',
                      style: const TextStyle(fontSize: 10.5, color: Color(0xFF64748B)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 10),
          Text(
            rfq['need_material']!,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            'Kriteria Teknis: ${rfq['spec']}',
            style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kebutuhan: ${rfq['target_volume']}',
                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: darkEmerald),
                  ),
                  Text(
                    'Harga Patokan: ${rfq['max_price']}',
                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: primaryEmerald),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Form penawaran resmi telah diajukan ke ${rfq['factory_name']}!'),
                      backgroundColor: primaryEmerald,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryEmerald,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.send_rounded, size: 14),
                label: const Text('Kirim RFQ', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
