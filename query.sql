-- 1. Tambahkan kolom metrik ke tabel companies (jika belum ada)
ALTER TABLE public.companies 
ADD COLUMN IF NOT EXISTS current_emission NUMERIC DEFAULT 0,
ADD COLUMN IF NOT EXISTS carbon_intensity NUMERIC DEFAULT 0,
ADD COLUMN IF NOT EXISTS energy_efficiency_trend NUMERIC DEFAULT 0,
ADD COLUMN IF NOT EXISTS national_rank INTEGER DEFAULT 0;

-- 2. (Opsional) Update perusahaan yang sudah pernah dibuat dengan data dummy ini 
-- agar tampilannya bagus (tidak angka 0 semua)
UPDATE public.companies 
SET 
  current_emission = 12450,
  carbon_intensity = 0.18,
  energy_efficiency_trend = 12,
  national_rank = 2
WHERE current_emission = 0; 


-- 3. Buat tabel 'emission_log' untuk mencatat status Dashboard Nasional
CREATE TABLE IF NOT EXISTS public.emission_log (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  total_emissions NUMERIC,
  trend_percentage NUMERIC,
  target_reduction NUMERIC,
  registered_factories INTEGER,
  avg_carbon_intensity NUMERIC,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Hapus data dummy lama jika Anda menjalankan kueri ini lebih dari sekali
TRUNCATE TABLE public.emission_log;

-- 4. Masukkan data dummy Nasional ke emission_log
INSERT INTO public.emission_log 
  (total_emissions, trend_percentage, target_reduction, registered_factories, avg_carbon_intensity)
VALUES 
  (2.86, 35, 45, 142, 0.15);

-- 5. Atur Keamanan Akses (RLS) untuk tabel emission_log
ALTER TABLE public.emission_log ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Enable read for all authenticated users" 
  ON public.emission_log FOR SELECT 
  USING (auth.role() = 'authenticated');


  



  -- ==============================================================
-- 1. HAPUS TABEL LAMA (Jika ada, agar tidak bentrok)
-- ==============================================================
DROP TABLE IF EXISTS public.authorized CASCADE;
DROP TABLE IF EXISTS public.companies CASCADE;
DROP TABLE IF EXISTS public.emission_log CASCADE;
DROP TABLE IF EXISTS public.top_factories CASCADE;


-- ==============================================================
-- 2. BUAT TABEL 'companies' (DATA PERUSAHAAN & EMISI BULANAN)
-- ==============================================================
CREATE TABLE public.companies (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  -- Relasi langsung ke tabel auth.users bawaan Supabase
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  
  -- Data Pribadi
  name TEXT NOT NULL,
  siinas_id TEXT NOT NULL,
  
  -- Metrik Emisi Perusahaan
  current_emission NUMERIC DEFAULT 0,
  emission_status TEXT DEFAULT 'Normal',
  carbon_intensity NUMERIC DEFAULT 0, 
  energy_efficiency_trend NUMERIC DEFAULT 0,
  national_rank INTEGER DEFAULT 0,
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);


-- ==============================================================
-- 3. BUAT TABEL 'emission_log' (DATA NASIONAL)
-- ==============================================================
CREATE TABLE public.emission_log (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  total_emissions NUMERIC,
  trend_percentage NUMERIC,
  target_reduction NUMERIC,
  registered_factories INTEGER,
  avg_carbon_intensity NUMERIC,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);


-- ==============================================================
-- 4. BUAT TABEL 'top_factories' (PERINGKAT PABRIK EFISIEN NASIONAL)
-- ==============================================================
CREATE TABLE public.top_factories (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  rank INTEGER,
  name TEXT,
  location TEXT,
  carbon_intensity NUMERIC,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);


-- ==============================================================
-- 5. MASUKKAN DATA DUMMY AWAL (INITIAL DATA)
-- ==============================================================

-- A. Data Dashboard Nasional
INSERT INTO public.emission_log 
  (total_emissions, trend_percentage, target_reduction, registered_factories, avg_carbon_intensity)
VALUES 
  (2.86, 35, 45, 142, 0.15);

-- B. Data Peringkat Nasional (Top Pabrik Paling Efisien)
INSERT INTO public.top_factories (rank, name, location, carbon_intensity) VALUES 
  (1, 'PT Krakatau Steel', 'Cilegon, Banten', 0.08),
  (2, 'PT Gunung Raja Paksi', 'Bekasi, Jawa Barat', 0.11), 
  (3, 'PT Bhirawa Steel', 'Surabaya, Jawa Timur', 0.12);


-- ==============================================================
-- 6. PENGATURAN KEAMANAN (ROW LEVEL SECURITY / RLS)
-- ==============================================================
ALTER TABLE public.companies ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.emission_log ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.top_factories ENABLE ROW LEVEL SECURITY;

-- Policy 'companies': Akun login hanya bisa melihat/mengedit data perusahaan miliknya sendiri
CREATE POLICY "Users can manage their own company" 
  ON public.companies FOR ALL 
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Policy Dashboard Nasional: Semua akun yang login bisa membaca (Select) datanya
CREATE POLICY "Enable read for authenticated users" 
  ON public.emission_log FOR SELECT 
  USING (auth.role() = 'authenticated');

-- Policy Top Factories: Semua akun yang login bisa membaca (Select) datanya
CREATE POLICY "Enable read for authenticated users" 
  ON public.top_factories FOR SELECT 
  USING (auth.role() = 'authenticated');


  -- Update data tabel compenies:
  ALTER TABLE public.companies ADD COLUMN IF NOT EXISTS avatar_url TEXT;



  -- ///// update tabel-tabel
  -- 1. Tambahkan kolom lokasi ke tabel companies agar formatnya cocok
ALTER TABLE public.companies ADD COLUMN IF NOT EXISTS location TEXT DEFAULT 'Indonesia';

-- 2. Hapus tabel top_factories yang lama 
DROP TABLE IF EXISTS public.top_factories CASCADE;

-- 3. Masukkan pabrik pembanding (Krakatau Steel dll) langsung ke tabel companies 
-- (user_id sengaja dikosongkan karena mereka bukan user login, hanya sebagai dummy pembanding nasional)
INSERT INTO public.companies (name, siinas_id, location, carbon_intensity) 
VALUES 
  ('PT Krakatau Steel', 'KS001', 'Cilegon, Banten', 0.08),
  ('PT Gunung Raja Paksi', 'GRP002', 'Bekasi, Jawa Barat', 0.11),
  ('PT Bhirawa Steel', 'BS003', 'Surabaya, Jawa Timur', 0.12);

-- 4. BUAT VIEW OTOMATIS: 'top_factories'
-- Sistem Supabase akan selalu menghitung peringkat secara LIVE setiap detiknya.
-- Siapa yang Intensitas Karbon-nya (carbon_intensity) paling kecil, dia otomatis ranking 1!
CREATE OR REPLACE VIEW public.top_factories AS
SELECT 
  ROW_NUMBER() OVER (ORDER BY carbon_intensity ASC) as rank,
  id as company_id,
  name,
  location,
  carbon_intensity
FROM public.companies
WHERE carbon_intensity > 0;

-- 1. Beri izin kepada user yang sudah login (authenticated) untuk MENGUNGGAH foto ke bucket 'profile_perusahaan'
CREATE POLICY "Izinkan user login upload foto" 
ON storage.objects FOR INSERT 
TO authenticated 
WITH CHECK (bucket_id = 'profile_perusahaan');

-- 2. Beri izin kepada user yang sudah login untuk MEMPERBARUI (replace) foto lama mereka
CREATE POLICY "Izinkan user login update foto" 
ON storage.objects FOR UPDATE 
TO authenticated 
USING (bucket_id = 'profile_perusahaan');

-- 3. Pastikan semua orang bisa MELIHAT foto tersebut (karena ini foto profil)
CREATE POLICY "Izinkan semua orang melihat foto" 
ON storage.objects FOR SELECT 
USING (bucket_id = 'profile_perusahaan');


-- 1. Hapus peraturan lama (kalau sebelumnya sempat di-Run)
DROP POLICY IF EXISTS "Izinkan user login upload foto" ON storage.objects;
DROP POLICY IF EXISTS "Izinkan user login update foto" ON storage.objects;
DROP POLICY IF EXISTS "Izinkan semua orang melihat foto" ON storage.objects;

-- 2. Buat ulang peraturan untuk MENGUNGGAH foto (sesuai nama typo)
CREATE POLICY "Izinkan user login upload foto" 
ON storage.objects FOR INSERT 
TO authenticated 
WITH CHECK (bucket_id = 'profile_perushaan');

-- 3. Buat ulang peraturan untuk MEMPERBARUI foto (sesuai nama typo)
CREATE POLICY "Izinkan user login update foto" 
ON storage.objects FOR UPDATE 
TO authenticated 
USING (bucket_id = 'profile_perushaan');

-- 4. Buat ulang peraturan untuk MELIHAT foto (sesuai nama typo)
CREATE POLICY "Izinkan semua orang melihat foto" 
ON storage.objects FOR SELECT 
USING (bucket_id = 'profile_perushaan');



-- 1. Buat Tabel Histori CBAM (Satu user punya banyak riwayat log)
CREATE TABLE public.cbam_logs (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  export_volume NUMERIC,
  carbon_intensity NUMERIC,
  destination TEXT,
  tax_amount_rp NUMERIC,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 2. Aktifkan Fitur Keamanan (RLS)
ALTER TABLE public.cbam_logs ENABLE ROW LEVEL SECURITY;

-- 3. Policy: User HANYA bisa melihat, menambah, dan mengedit log milik mereka sendiri (Tidak bisa melihat punya orang lain)
CREATE POLICY "Users can manage their own CBAM logs" 
  ON public.cbam_logs FOR ALL 
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);







  -- 1. Buat Tabel (Jika Belum Ada) atau Tambahkan Kolom Baru
CREATE TABLE IF NOT EXISTS public.green_vendor_markets (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  category TEXT NOT NULL,
  location TEXT,
  description TEXT,
  info_label TEXT,
  info_value TEXT,
  verification_status BOOLEAN DEFAULT false,
  badge_text TEXT,
  badge_icon TEXT,
  icon_name TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Jaga-jaga jika tabel sudah ada namun belum memiliki kolom-kolom baru di atas:
ALTER TABLE public.green_vendor_markets 
ADD COLUMN IF NOT EXISTS location TEXT,
ADD COLUMN IF NOT EXISTS description TEXT,
ADD COLUMN IF NOT EXISTS info_label TEXT,
ADD COLUMN IF NOT EXISTS info_value TEXT,
ADD COLUMN IF NOT EXISTS verification_status BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS badge_text TEXT,
ADD COLUMN IF NOT EXISTS badge_icon TEXT,
ADD COLUMN IF NOT EXISTS icon_name TEXT;

-- 2. Hapus data lama agar tidak dobel/berantakan
TRUNCATE TABLE public.green_vendor_markets;

-- 3. Insert 10 Data Dummy!
INSERT INTO public.green_vendor_markets 
  (name, category, location, description, info_label, info_value, verification_status, badge_text, badge_icon, icon_name)
VALUES 
  (
    'PT IndoEAF Technologies', 
    'Teknologi EAF', 
    'Jakarta Barat', 
    'Penyedia Mesin Electric Arc Furnace (EAF) skala menengah dengan konsumsi listrik efisien.', 
    'Efisiensi Karbon:', 
    '-45%', 
    true, 
    'Verified Vendor', 
    NULL, 
    'factory'
  ),
  (
    'Koperasi Scrap Baja Jatim', 
    'Bahan Baku Sirkular (UMKM)', 
    'Jawa Timur', 
    'Pengepul besi tua (scrap) skala besar untuk bahan baku baja daur ulang (Circular Steel).', 
    'Kapasitas Suplai:', 
    '5.000 Ton/Bulan', 
    false, 
    'Koperasi UMKM', 
    'groups', 
    'precision_manufacturing'
  ),
  (
    'SolarIndo EPC', 
    'Energi Terbarukan', 
    'Banten', 
    'Instalasi Panel Surya Atap Pabrik (On-Grid) khusus untuk kawasan industri berat.', 
    'Potensi Penghematan PLN:', 
    '30%', 
    true, 
    'Verified Vendor', 
    NULL, 
    'solar_power'
  ),
  (
    'EcoSteel Recycling Hub', 
    'Bahan Baku Sirkular (UMKM)', 
    'Cikarang, Bekasi', 
    'Mitra daur ulang baja industri, mengubah limbah logam menjadi bahan baku siap lebur.', 
    'Kapasitas Suplai:', 
    '2.500 Ton/Bulan', 
    true, 
    'Verified Vendor', 
    NULL, 
    'recycling'
  ),
  (
    'GreenTech Furnace Solutions', 
    'Teknologi EAF', 
    'Surabaya', 
    'Pabrikan komponen tungku busur listrik dengan sertifikasi emisi rendah.', 
    'Efisiensi Karbon:', 
    '-35%', 
    true, 
    'Verified Vendor', 
    NULL, 
    'factory'
  ),
  (
    'Nusantara Biomass', 
    'Energi Terbarukan', 
    'Kalimantan Timur', 
    'Penyedia pelet biomassa dari limbah kelapa sawit sebagai substitusi parsial batu bara.', 
    'Reduksi Emisi:', 
    'Sampai 20%', 
    false, 
    'B2B Startup', 
    'eco', 
    'eco'
  ),
  (
    'PT Baja Sirkular Mandiri', 
    'Bahan Baku Sirkular (UMKM)', 
    'Semarang', 
    'Jaringan pengepul scrap besi dan baja skala menengah untuk industri.', 
    'Kapasitas Suplai:', 
    '1.200 Ton/Bulan', 
    false, 
    'Koperasi UMKM', 
    'groups', 
    'precision_manufacturing'
  ),
  (
    'WindPower Indonesia', 
    'Energi Terbarukan', 
    'Sulawesi Selatan', 
    'Penyedia pasokan listrik dari tenaga angin skala besar (PPA) untuk manufaktur.', 
    'Sertifikat Energi Hijau:', 
    'Tersedia', 
    true, 
    'Verified Vendor', 
    NULL, 
    'solar_power'
  ),
  (
    'EAF Modernization Inc.', 
    'Teknologi EAF', 
    'Batam', 
    'Layanan retrofit dan modernisasi tungku baja lama menjadi teknologi EAF yang hemat energi.', 
    'Peningkatan Efisiensi:', 
    '+25%', 
    true, 
    'Verified Vendor', 
    NULL, 
    'factory'
  ),
  (
    'Scrap Nusantara Jaya', 
    'Bahan Baku Sirkular (UMKM)', 
    'Medan', 
    'Penyedia scrap otomotif terpilah berkualitas tinggi untuk industri peleburan baja.', 
    'Kapasitas Suplai:', 
    '3.000 Ton/Bulan', 
    false, 
    'Koperasi UMKM', 
    'groups', 
    'recycling'
  );


create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.users (id, company_name, industry_type)
  values (
    new.id, 
    COALESCE(new.raw_user_meta_data->>'company_name', new.raw_user_meta_data->>'full_name', 'Pengguna Google'), 
    COALESCE(new.raw_user_meta_data->>'industry_type', 'Belum Ditentukan')
  );
  return new;
end;
$$;

-- 1. Perbarui fungsi agar memasukkan data ke tabel 'companies' (BUKAN 'users')
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER SET search_path = public
AS $$
BEGIN
  INSERT INTO public.companies (user_id, name, siinas_id)
  VALUES (
    new.id, 
    -- Ambil nama perusahaan dari register email, JIKA KOSONG (Google) ambil nama akun Google-nya
    COALESCE(new.raw_user_meta_data->>'company_name', new.raw_user_meta_data->>'full_name', 'Pengguna Google'), 
    
    -- Ambil data industri dari register email dan masukkan ke siinas_id, JIKA KOSONG (Google) isi default
    COALESCE(new.raw_user_meta_data->>'industry_type', 'Tidak Ditentukan')
  );
  RETURN new;
END;
$$;

-- 2. Pastikan Trigger aktif pada tabel auth.users bawaan Supabase
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();