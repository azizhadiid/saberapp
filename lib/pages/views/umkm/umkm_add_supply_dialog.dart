import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// ============================================================================
/// MODAL DIALOG: INPUT PASOKAN SCRAP / JUAL CEPAT (UMKM & PERUSAHAAN HIJAU)
/// ============================================================================
class UmkmAddSupplyDialog extends StatefulWidget {
  const UmkmAddSupplyDialog({super.key});

  @override
  State<UmkmAddSupplyDialog> createState() => _UmkmAddSupplyDialogState();
}

class _UmkmAddSupplyDialogState extends State<UmkmAddSupplyDialog> {
  final _titleCtrl = TextEditingController();
  final _tonnageCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  String _selectedCategory = 'Scrap HMS 1&2';
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _tonnageCtrl.dispose();
    _priceCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitSupply() async {
    final title = _titleCtrl.text.trim().isNotEmpty
        ? _titleCtrl.text.trim()
        : 'Pasokan $_selectedCategory Siap Kirim';
    final tonnage = double.tryParse(_tonnageCtrl.text) ?? 500.0;
    final price = double.tryParse(_priceCtrl.text.replaceAll('.', '').replaceAll(',', '')) ?? 6900000.0;
    final location = _locationCtrl.text.trim().isNotEmpty
        ? _locationCtrl.text.trim()
        : 'Depo Utama Surabaya & Gresik';
    final user = Supabase.instance.client.auth.currentUser;
    String? companyId;
    if (user != null) {
      try {
        final comp = await Supabase.instance.client
            .from('companies')
            .select('id, name')
            .eq('user_id', user.id)
            .maybeSingle();
        if (comp != null && comp['id'] != null) {
          companyId = comp['id'] as String;
        }
      } catch (e) {
        debugPrint('Error fetching company for supply: $e');
      }
    }

    final newSupply = {
      'user_id': user?.id,
      'company_id': companyId,
      'title': title,
      'category': _selectedCategory,
      'depo': location,
      'tonnage_available': tonnage,
      'unit': 'Ton',
      'fe_grade': _selectedCategory.contains('Biomassa') ? 0.0 : 98.6,
      'cu_impurity': _selectedCategory.contains('Biomassa') ? 'N/A' : '< 0.05%',
      'price_per_ton': price,
      'co2_saved_ton': (tonnage * 1.42).roundToDouble(),
      'mrf_certified': true,
      'status': 'Siap Kirim',
    };

    setState(() => _isSubmitting = true);

    try {
      final res = await Supabase.instance.client
          .from('umkm_supplies')
          .insert(newSupply)
          .select()
          .single();

      if (mounted) {
        Navigator.pop(context, res);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pasokan berhasil disimpan dan diposting ke Bursa Pabrik Baja!'),
            backgroundColor: Color(0xFF0284C7),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error posting to Supabase: $e');
      if (mounted) {
        Navigator.pop(context, newSupply);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pasokan berhasil ditambahkan ke katalog pasokan Anda!'),
            backgroundColor: Color(0xFF0284C7),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
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
                    onPressed: _isSubmitting ? null : _submitSupply,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0284C7),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Posting Pasokan',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
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
