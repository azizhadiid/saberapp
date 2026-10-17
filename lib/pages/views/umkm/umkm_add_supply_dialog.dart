import 'package:flutter/material.dart';

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
