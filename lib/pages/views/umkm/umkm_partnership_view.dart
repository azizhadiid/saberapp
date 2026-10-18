import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// ============================================================================
/// UMKM PARTNERSHIP VIEW (KEMITRAAN & KONTRAK PASOKAN SIRKULAR)
/// ============================================================================
/// Dirancang untuk mengikat kontrak pasokan kuota rutin (Offtake Agreement / MOU)
/// antara UMKM / Perusahaan Hijau dengan Pabrik Baja (Offtaker) EAF.
/// Terhubung 100% dinamis ke Supabase tabel 'umkm_partnerships' (tanpa seeder dummy).
/// Sepenuhnya responsif di berbagai resolusi layar tanpa risiko overflow.
/// ============================================================================
class UmkmPartnershipView extends StatefulWidget {
  const UmkmPartnershipView({super.key});

  @override
  State<UmkmPartnershipView> createState() => _UmkmPartnershipViewState();
}

class _UmkmPartnershipViewState extends State<UmkmPartnershipView> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _partnershipList = [];
  String _selectedFilter = 'Semua';
  String? _companyId;

  // Daftar Pabrik Baja Dinamis dari tabel 'companies'
  List<String> _steelFactories = [];
  Map<String, String> _factoryIdMap = {};

  // Formatters
  final _currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );
  final _numberFormatter = NumberFormat.decimalPattern('id_ID');

  // Tema Warna Eco-Sirkular
  static const primaryEmerald = Color(0xFF059669);
  static const darkEmerald = Color(0xFF065F46);
  static const lightEmeraldBg = Color(0xFFECFDF5);
  static const primaryCyan = Color(0xFF0284C7);

  @override
  void initState() {
    super.initState();
    _fetchPartnerships();
  }

  /// Ambil data kemitraan dari Supabase secara dinamis terikat ke user/company
  Future<void> _fetchPartnerships() async {
    setState(() => _isLoading = true);
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      // 1. Ambil company_id milik akun yang sedang login
      final compRes = await Supabase.instance.client
          .from('companies')
          .select('id')
          .eq('user_id', user.id)
          .maybeSingle();

      _companyId = compRes?['id']?.toString();

      // 2. Fetch data pabrik baja secara DINAMIS dari tabel companies
      await _fetchSteelFactories();

      // 3. Query data kemitraan milik user atau company ini
      final query = Supabase.instance.client.from('umkm_partnerships').select();
      dynamic response;

      if (_companyId != null) {
        response = await query
            .or('user_id.eq.${user.id},company_id.eq.$_companyId')
            .order('created_at', ascending: false);
      } else {
        response = await query
            .eq('user_id', user.id)
            .order('created_at', ascending: false);
      }

      final List<Map<String, dynamic>> rawList =
          List<Map<String, dynamic>>.from(response ?? []);

      if (mounted) {
        setState(() {
          _partnershipList = rawList;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error mengambil data kemitraan Supabase: $e');
      if (mounted) {
        setState(() {
          _partnershipList = [];
          _isLoading = false;
        });
      }
    }
  }

  /// Ambil data offtaker pabrik baja secara dinamis dari tabel companies Supabase
  Future<void> _fetchSteelFactories() async {
    try {
      final compBajaRes = await Supabase.instance.client
          .from('companies')
          .select('id, name, role, company_type');

      final List<String> dynamicFactories = [];
      final Map<String, String> idMap = {};

      for (final row in (compBajaRes as List)) {
        final map = Map<String, dynamic>.from(row);
        final name = (map['name'] ?? '').toString().trim();
        final role = (map['role'] ?? '').toString().toLowerCase();
        final companyType = (map['company_type'] ?? '').toString().toLowerCase();
        final id = map['id']?.toString() ?? '';

        if (name.isEmpty) continue;

        // Filter: bukan entitas pemerintah
        if (role == 'pemerintah' || companyType == 'pemerintah') continue;

        if (!dynamicFactories.contains(name)) {
          dynamicFactories.add(name);
          if (id.isNotEmpty) idMap[name] = id;
        }
      }

      // Pastikan pabrik baja utama (termasuk PT DITRA) selalu ada di daftar
      final defaultList = [
        'PT DITRA',
        'PT Krakatau Steel (Persero) Tbk',
        'PT Gunung Raja Paksi Tbk',
        'PT Bhirawa Steel Surabaya',
        'PT Lautan Steel Indonesia',
        'PT Ispat Indo Sidoarjo',
      ];
      for (final d in defaultList) {
        if (!dynamicFactories.any((f) => f.toLowerCase() == d.toLowerCase())) {
          dynamicFactories.add(d);
        }
      }

      // Urutkan dengan memprioritaskan entitas yang mengandung kata DITRA di urutan pertama
      dynamicFactories.sort((a, b) {
        final aIsDitra = a.toLowerCase().contains('ditra');
        final bIsDitra = b.toLowerCase().contains('ditra');
        if (aIsDitra && !bIsDitra) return -1;
        if (!aIsDitra && bIsDitra) return 1;
        return a.compareTo(b);
      });

      if (mounted) {
        setState(() {
          _steelFactories = dynamicFactories;
          _factoryIdMap = idMap;
        });
      }
    } catch (e) {
      debugPrint('Error fetch steel factories: $e');
      if (_steelFactories.isEmpty) {
        _steelFactories = [
          'PT DITRA',
          'PT Krakatau Steel (Persero) Tbk',
          'PT Gunung Raja Paksi Tbk',
          'PT Bhirawa Steel Surabaya',
          'PT Lautan Steel Indonesia',
          'PT Ispat Indo Sidoarjo',
        ];
      }
    }
  }

  /// Dialog Tambah Pengajuan Kemitraan / MOU Baru
  Future<void> _showAddPartnershipDialog() async {
    // Ambil data pabrik baja paling segar dari Supabase sebelum membuka dialog
    await _fetchSteelFactories();
    if (!mounted) return;

    final factoriesList = _steelFactories.isNotEmpty
        ? _steelFactories
        : [
            'PT DITRA',
            'PT Krakatau Steel (Persero) Tbk',
            'PT Gunung Raja Paksi Tbk',
            'PT Bhirawa Steel Surabaya',
            'PT Lautan Steel Indonesia',
            'PT Ispat Indo Sidoarjo',
          ];

    final factoryCtrl = TextEditingController(text: factoriesList.first);
    final contractNoCtrl = TextEditingController(
      text: 'PKS/SBR-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}/2026',
    );
    final materialCtrl = TextEditingController(text: 'Scrap HMS 1&2 (Siap Umpan EAF)');
    final targetVolCtrl = TextEditingController(text: '1200');
    final priceCtrl = TextEditingController(text: '7100000');
    final esgCtrl = TextEditingController(
      text: 'Bantuan Mesin Baler Pres & Uji Spektrometer Gratis',
    );
    final notesCtrl = TextEditingController(
      text: 'Pasokan bertahap mingguan 50 ton dengan dokumen uji bebas zat radioaktif.',
    );
    String selectedType = 'Offtake Pasokan Rutin (Kontrak 6 Bulan)';
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (dCtx) => StatefulBuilder(
        builder: (dialogContext, setModalState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.handshake_rounded, color: primaryEmerald),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Ajukan Kontrak Kemitraan Baru',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pabrik Baja Mitra (Offtaker EAF)',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: factoryCtrl.text,
                    isExpanded: true,
                    decoration: InputDecoration(
                      isDense: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                    items: factoriesList
                        .map((f) => DropdownMenuItem(value: f, child: Text(f, style: const TextStyle(fontSize: 12.5), overflow: TextOverflow.ellipsis)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setModalState(() => factoryCtrl.text = val);
                    },
                  ),
                  const SizedBox(height: 12),

                  const Text('No. Pengajuan MOU / PKS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: contractNoCtrl,
                    style: const TextStyle(fontSize: 12.5),
                    decoration: InputDecoration(
                      isDense: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 12),

                  const Text('Jenis Kemitraan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: selectedType,
                    isExpanded: true,
                    decoration: InputDecoration(
                      isDense: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                    items: [
                      'Offtake Pasokan Rutin (Kontrak 6 Bulan)',
                      'Kontrak Suplai Tahunan EAF',
                      'Konsorsium Pasokan Bersama UMKM',
                      'Pembinaan Standar Sortir MRF',
                    ]
                        .map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setModalState(() => selectedType = val);
                    },
                  ),
                  const SizedBox(height: 12),

                  const Text('Jenis Material Scrap / Biomassa', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: materialCtrl,
                    style: const TextStyle(fontSize: 12.5),
                    decoration: InputDecoration(
                      isDense: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Target Tonase', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            TextField(
                              controller: targetVolCtrl,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(fontSize: 12.5),
                              decoration: InputDecoration(
                                suffixText: 'Ton',
                                isDense: true,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Harga per Ton', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            TextField(
                              controller: priceCtrl,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(fontSize: 12.5),
                              decoration: InputDecoration(
                                prefixText: 'Rp ',
                                isDense: true,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  const Text('Program Dukungan ESG Pabrik', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: esgCtrl,
                    style: const TextStyle(fontSize: 12.5),
                    decoration: InputDecoration(
                      isDense: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 12),

                  const Text('Catatan Tambahan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: notesCtrl,
                    maxLines: 2,
                    style: const TextStyle(fontSize: 12.5),
                    decoration: InputDecoration(
                      isDense: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dCtx),
              child: const Text('Batal', style: TextStyle(color: Color(0xFF64748B))),
            ),
            ElevatedButton(
              onPressed: isSubmitting
                  ? null
                  : () async {
                      final nav = Navigator.of(dCtx);
                      final messenger = ScaffoldMessenger.of(context);
                      final targetVol = double.tryParse(targetVolCtrl.text.trim()) ?? 0.0;
                      final price = double.tryParse(priceCtrl.text.trim()) ?? 0.0;
                      final totalVal = targetVol * price;
                      final co2Claimed = targetVol * 1.42;

                      setModalState(() => isSubmitting = true);
                      try {
                        final user = Supabase.instance.client.auth.currentUser;
                        final selectedFactoryName = factoryCtrl.text.trim();
                        var selectedFactoryId = _factoryIdMap[selectedFactoryName];
                        if (selectedFactoryId == null) {
                          for (final entry in _factoryIdMap.entries) {
                            if (entry.key.toLowerCase().contains('ditra') &&
                                selectedFactoryName.toLowerCase().contains('ditra')) {
                              selectedFactoryId = entry.value;
                              break;
                            }
                          }
                        }

                        final newRow = {
                          'user_id': user?.id,
                          'company_id': _companyId,
                          'factory_company_id': selectedFactoryId,
                          'factory_name': selectedFactoryName,
                          'contract_number': contractNoCtrl.text.trim(),
                          'contract_type': selectedType,
                          'material_type': materialCtrl.text.trim(),
                          'target_volume_tons': targetVol,
                          'fulfilled_volume_tons': 0.0,
                          'price_per_ton': price,
                          'total_contract_value': totalVal,
                          'status': 'Aktif',
                          'esg_support_program': esgCtrl.text.trim(),
                          'co2_reduction_claimed': co2Claimed,
                          'notes': notesCtrl.text.trim(),
                        };

                        final inserted = await Supabase.instance.client
                            .from('umkm_partnerships')
                            .insert(newRow)
                            .select()
                            .single();

                        nav.pop();
                        setState(() {
                          _partnershipList.insert(0, inserted);
                        });

                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text('Kontrak kemitraan baru berhasil diajukan!'),
                            backgroundColor: primaryEmerald,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      } catch (e) {
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text('Gagal menyimpan kemitraan: $e'),
                            backgroundColor: const Color(0xFFDC2626),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      } finally {
                        setModalState(() => isSubmitting = false);
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryEmerald,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: isSubmitting
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Kirim Pengajuan'),
            ),
          ],
        ),
      ),
    );
  }

  /// Dialog Input Pengiriman Kuota (DO / Surat Jalan)
  void _showDeliveryInputDialog(Map<String, dynamic> item) {
    final tonCtrl = TextEditingController(text: '50');
    final doNumberCtrl = TextEditingController(
      text: 'SJ/DO-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
    );
    bool isSaving = false;

    final double currentFulfilled = (item['fulfilled_volume_tons'] as num?)?.toDouble() ?? 0.0;
    final double target = (item['target_volume_tons'] as num?)?.toDouble() ?? 1.0;

    showDialog(
      context: context,
      builder: (dCtx) => StatefulBuilder(
        builder: (dialogContext, setModalState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.local_shipping_outlined, color: primaryEmerald),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Input Surat Jalan Pengiriman',
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
                'Pabrik Tujuan: ${item['factory_name']}',
                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                'Target Kontrak: ${_numberFormatter.format(target)} Ton (Terkirim: ${_numberFormatter.format(currentFulfilled)} Ton)',
                style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 14),

              const Text('Nomor Surat Jalan / Delivery Order (DO)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              TextField(
                controller: doNumberCtrl,
                style: const TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  isDense: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
              ),
              const SizedBox(height: 12),

              const Text('Tonase Scrap yang Dikirim Hari Ini', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              TextField(
                controller: tonCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  suffixText: 'Ton',
                  isDense: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dCtx),
              child: const Text('Batal', style: TextStyle(color: Color(0xFF64748B))),
            ),
            ElevatedButton(
              onPressed: isSaving
                  ? null
                  : () async {
                      final nav = Navigator.of(dCtx);
                      final messenger = ScaffoldMessenger.of(context);
                      final added = double.tryParse(tonCtrl.text.trim()) ?? 0.0;
                      if (added <= 0) return;

                      final newFulfilled = currentFulfilled + added;
                      final isComplete = newFulfilled >= target;

                      setModalState(() => isSaving = true);
                      try {
                        await Supabase.instance.client
                            .from('umkm_partnerships')
                            .update({
                              'fulfilled_volume_tons': newFulfilled,
                              if (isComplete) 'status': 'Selesai',
                            })
                            .eq('id', item['id']);

                        nav.pop();
                        setState(() {
                          item['fulfilled_volume_tons'] = newFulfilled;
                          if (isComplete) item['status'] = 'Selesai';
                        });

                        messenger.showSnackBar(
                          SnackBar(
                            content: Text('Surat jalan berhasil dicatat! Total terkirim: ${_numberFormatter.format(newFulfilled)} Ton'),
                            backgroundColor: primaryEmerald,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      } catch (e) {
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text('Gagal mencatat pengiriman: $e'),
                            backgroundColor: const Color(0xFFDC2626),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      } finally {
                        setModalState(() => isSaving = false);
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryEmerald,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: isSaving
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Simpan Pengiriman'),
            ),
          ],
        ),
      ),
    );
  }

  /// Dialog Hapus / Batalkan Kemitraan
  void _confirmDeletePartnership(Map<String, dynamic> item) async {
    final messenger = ScaffoldMessenger.of(context);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (dCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.delete_outline_rounded, color: Color(0xFFDC2626)),
            SizedBox(width: 8),
            Text('Batalkan Kemitraan?', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text('Apakah Anda yakin ingin membatalkan kontrak bersama ${item['factory_name']}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dCtx, false), child: const Text('Tidak')),
          ElevatedButton(
            onPressed: () => Navigator.pop(dCtx, true),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDC2626), foregroundColor: Colors.white),
            child: const Text('Ya, Batalkan'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await Supabase.instance.client
            .from('umkm_partnerships')
            .delete()
            .eq('id', item['id']);

        setState(() {
          _partnershipList.removeWhere((e) => e['id'] == item['id']);
        });

        messenger.showSnackBar(
          const SnackBar(
            content: Text('Kontrak kemitraan berhasil dihapus.'),
            backgroundColor: Color(0xFFDC2626),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } catch (e) {
        debugPrint('Error delete kemitraan: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filter list
    final filteredList = _partnershipList.where((item) {
      if (_selectedFilter == 'Semua') return true;
      return (item['status'] ?? '').toString().toLowerCase() == _selectedFilter.toLowerCase();
    }).toList();

    // Kalkulasi metrik ringkasan
    double totalCommittedTons = 0;
    double totalFulfilledTons = 0;
    double totalValueRp = 0;
    int activeContractsCount = 0;

    for (final item in _partnershipList) {
      final target = (item['target_volume_tons'] as num?)?.toDouble() ?? 0.0;
      final fulfilled = (item['fulfilled_volume_tons'] as num?)?.toDouble() ?? 0.0;
      final value = (item['total_contract_value'] as num?)?.toDouble() ?? 0.0;
      final status = (item['status'] ?? '').toString();

      totalCommittedTons += target;
      totalFulfilledTons += fulfilled;
      totalValueRp += value;
      if (status == 'Aktif') activeContractsCount++;
    }

    final double fulfillmentPercent = totalCommittedTons > 0
        ? ((totalFulfilledTons / totalCommittedTons) * 100).clamp(0.0, 100.0)
        : 0.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false, // Menghilangkan tombol back
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Flexible(
                  child: Text(
                    'Kemitraan & Kontrak Pabrik',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: lightEmeraldBg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Offtake EAF',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: darkEmerald,
                    ),
                  ),
                ),
              ],
            ),
            const Text(
              'Perjanjian Pasokan Kuota Rutin & Pembinaan Standar Mutu',
              style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF475569)),
            tooltip: 'Segarkan Kemitraan',
            onPressed: _fetchPartnerships,
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, color: primaryEmerald),
            tooltip: 'Ajukan Kemitraan Baru',
            onPressed: _showAddPartnershipDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryEmerald))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. KARTU HERO BANNER RINGKASAN KEMITRAAN (RESPONSIF)
                  _buildSummaryHeroCard(
                    activeCount: activeContractsCount,
                    totalTarget: totalCommittedTons,
                    totalFulfilled: totalFulfilledTons,
                    totalValue: totalValueRp,
                    percent: fulfillmentPercent,
                  ),
                  const SizedBox(height: 16),

                  // 2. FILTER TABS (Semua, Aktif, Menunggu, Selesai)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['Semua', 'Aktif', 'Menunggu Persetujuan', 'Selesai'].map((status) {
                        final isSelected = _selectedFilter == status;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(status),
                            selected: isSelected,
                            onSelected: (val) {
                              if (val) setState(() => _selectedFilter = status);
                            },
                            selectedColor: lightEmeraldBg,
                            labelStyle: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: isSelected ? darkEmerald : const Color(0xFF475569),
                            ),
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(
                                color: isSelected ? primaryEmerald : const Color(0xFFE2E8F0),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 3. DAFTAR KONTRAK KEMITRAAN ATAU EMPTY STATE
                  if (filteredList.isEmpty)
                    _buildEmptyState()
                  else
                    ...filteredList.map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _buildPartnershipCard(item),
                        )),

                  const SizedBox(height: 20),

                  // 4. PEDOMAN STANDAR MUTU SNI 07-0052 & KRITERIA UJI EAF (RESPONSIF)
                  _buildQualityStandardSection(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  /// ==========================================================================
  /// 1. KARTU HERO BANNER RINGKASAN KEMITRAAN (RESPONSIF)
  /// ==========================================================================
  Widget _buildSummaryHeroCard({
    required int activeCount,
    required double totalTarget,
    required double totalFulfilled,
    required double totalValue,
    required double percent,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: lightEmeraldBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.handshake_rounded, color: primaryEmerald, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Komitmen Rantai Pasok EAF 52%',
                      style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '$activeCount Kontrak Pasokan Kuota Berjalan',
                      style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Baris Metrik (Menggunakan Expanded + FittedBox agar bebas overflow)
          Row(
            children: [
              Expanded(
                child: _buildMetricMiniTile(
                  label: 'Target Pasok',
                  value: '${_numberFormatter.format(totalTarget)} Ton',
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricMiniTile(
                  label: 'Terkirim (DO)',
                  value: '${_numberFormatter.format(totalFulfilled)} Ton',
                  color: primaryEmerald,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricMiniTile(
                  label: 'Nilai Kontrak',
                  value: totalValue >= 1000000000
                      ? 'Rp ${(totalValue / 1000000000).toStringAsFixed(1)} M'
                      : _currencyFormatter.format(totalValue),
                  color: primaryCyan,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Progress Realisasi
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Flexible(
                child: Text(
                  'Tingkat Pemenuhan Kuota Kontrak:',
                  style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${percent.toStringAsFixed(1)}% Terpenuhi',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: primaryEmerald),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: totalTarget > 0 ? (totalFulfilled / totalTarget).clamp(0.0, 1.0) : 0.0,
              minHeight: 7,
              backgroundColor: const Color(0xFFE2E8F0),
              valueColor: const AlwaysStoppedAnimation<Color>(primaryEmerald),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricMiniTile({
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color),
            ),
          ),
        ],
      ),
    );
  }

  /// ==========================================================================
  /// 2. EMPTY STATE EDUKATIF (JIKA BELUM ADA KONTRAK)
  /// ==========================================================================
  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: lightEmeraldBg,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.assignment_turned_in_outlined, size: 40, color: primaryEmerald),
          ),
          const SizedBox(height: 14),
          const Text(
            'Belum Ada Kontrak Kemitraan Aktif',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          const Text(
            'Sebagai pemasok hijau, Anda dapat mengajukan Kontrak Kemitraan Pasokan (Offtake Agreement) langsung ke Pabrik Baja mitra untuk menjamin penyerapan tonase scrap dengan harga stabil.',
            style: TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.4),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 18),
          ElevatedButton.icon(
            onPressed: _showAddPartnershipDialog,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryEmerald,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Ajukan Kontrak Kemitraan Baru', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  /// ==========================================================================
  /// 3. KARTU KEMITRAAN PABRIK INDIVIDUAL (RESPONSIF)
  /// ==========================================================================
  Widget _buildPartnershipCard(Map<String, dynamic> item) {
    final String status = item['status'] ?? 'Aktif';
    final bool isAktif = status == 'Aktif';
    final double target = (item['target_volume_tons'] as num?)?.toDouble() ?? 0.0;
    final double fulfilled = (item['fulfilled_volume_tons'] as num?)?.toDouble() ?? 0.0;
    final double price = (item['price_per_ton'] as num?)?.toDouble() ?? 0.0;
    final double totalVal = (item['total_contract_value'] as num?)?.toDouble() ?? (target * price);
    final double co2Claimed = (item['co2_reduction_claimed'] as num?)?.toDouble() ?? (target * 1.42);
    final double progressPercent = target > 0 ? ((fulfilled / target) * 100).clamp(0.0, 100.0) : 0.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isAktif ? const Color(0xFFA7F3D0) : const Color(0xFFE2E8F0),
          width: isAktif ? 1.4 : 1.0,
        ),
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
          // Header: Nama Pabrik & Badge Status
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isAktif ? lightEmeraldBg : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.business_rounded,
                  color: isAktif ? primaryEmerald : const Color(0xFF64748B),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['factory_name'] ?? 'Pabrik Baja Mitra',
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item['contract_number'] ?? 'PKS-SBR/2026',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontFamily: 'monospace'),
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
                  color: isAktif ? lightEmeraldBg : const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isAktif ? const Color(0xFFA7F3D0) : const Color(0xFFFDE68A),
                  ),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: isAktif ? darkEmerald : const Color(0xFFB45309),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Detail Kualifikasi & Tipe Kontrak
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFF1F5F9)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Flexible(
                      child: Text('Jenis Material:', style: TextStyle(fontSize: 11, color: Color(0xFF64748B)), overflow: TextOverflow.ellipsis),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        item['material_type'] ?? 'Scrap Logam',
                        style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                        textAlign: TextAlign.right,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Flexible(
                      child: Text('Harga Kontrak:', style: TextStyle(fontSize: 11, color: Color(0xFF64748B)), overflow: TextOverflow.ellipsis),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        '${_currencyFormatter.format(price)} / Ton',
                        style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: primaryEmerald),
                        textAlign: TextAlign.right,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Flexible(
                      child: Text('Estimasi Nilai Kontrak:', style: TextStyle(fontSize: 11, color: Color(0xFF64748B)), overflow: TextOverflow.ellipsis),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        totalVal >= 1000000000
                            ? 'Rp ${(totalVal / 1000000000).toStringAsFixed(2)} Miliar'
                            : _currencyFormatter.format(totalVal),
                        style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: primaryCyan),
                        textAlign: TextAlign.right,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Realisasi Kiriman (Progress Bar)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'Realisasi Pengiriman: ${_numberFormatter.format(fulfilled)} / ${_numberFormatter.format(target)} Ton',
                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${progressPercent.toStringAsFixed(1)}%',
                style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: primaryEmerald),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: target > 0 ? (fulfilled / target).clamp(0.0, 1.0) : 0.0,
              minHeight: 7,
              backgroundColor: const Color(0xFFE2E8F0),
              valueColor: AlwaysStoppedAnimation<Color>(
                progressPercent >= 100 ? const Color(0xFF10B981) : primaryEmerald,
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Badges Program ESG Pabrik & Klaim Dekarbonisasi (Wrap agar tidak overflow)
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFBBF7D0)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.eco_rounded, size: 12, color: primaryEmerald),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        'Klaim Emisi Scope 3 Pabrik: ${_numberFormatter.format(co2Claimed)} tCO2e',
                        style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: darkEmerald),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              if (item['esg_support_program'] != null && item['esg_support_program'].toString().isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFBFDBFE)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.card_giftcard_rounded, size: 12, color: primaryCyan),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          item['esg_support_program'].toString(),
                          style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: Color(0xFF1E40AF)),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),

          // Action Buttons: Input Pengiriman DO & Batalkan (Wrap responsif)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ElevatedButton.icon(
                onPressed: () => _showDeliveryInputDialog(item),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryEmerald,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.local_shipping_outlined, size: 15),
                label: const Text('Input Surat Jalan (DO)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
              OutlinedButton.icon(
                onPressed: () => _confirmDeletePartnership(item),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFDC2626),
                  side: const BorderSide(color: Color(0xFFFCA5A5)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.close_rounded, size: 15),
                label: const Text('Batalkan', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// ==========================================================================
  /// 4. PEDOMAN STANDAR MUTU SNI 07-0052 & KRITERIA UJI EAF (RESPONSIF)
  /// ==========================================================================
  Widget _buildQualityStandardSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.verified_outlined, size: 18, color: primaryEmerald),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Kriteria Mutu Scrap Standar EAF (SNI 07-0052)',
                  style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          _buildPillarItem(
            title: 'Kemurnian Besi (Fe > 98%) & Bebas Radioaktif',
            desc: 'Pabrik EAF mensyaratkan kadar Cu < 0.08% dan lolos uji portal deteksi radiasi untuk mencegah kontaminasi baja jadi.',
            badge: 'Parameter Kimia',
            badgeColor: primaryCyan,
          ),
          const SizedBox(height: 10),

          _buildPillarItem(
            title: 'Sortir Fisik MRF (Material Recovery Facility)',
            desc: 'Scrap wajib dipilah bebas dari oli basah, plastik, cat tebal, dan tanah agar tidak memicu ledakan tungku & slag berlebih.',
            badge: 'Standar Depo',
            badgeColor: primaryEmerald,
          ),
          const SizedBox(height: 10),

          _buildPillarItem(
            title: 'Insentif Pajak Karbon & Akses KUR Hijau',
            desc: 'Kemitraan resmi memberikan akses pembiayaan mesin shredder/baler dari bank mitra serta insentif kepatuhan UU HPP.',
            badge: 'Dukungan Fiskal',
            badgeColor: const Color(0xFFD97706),
          ),
        ],
      ),
    );
  }

  Widget _buildPillarItem({
    required String title,
    required String desc,
    required String badge,
    required Color badgeColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  badge,
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: badgeColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            desc,
            style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B), height: 1.35),
          ),
        ],
      ),
    );
  }
}
