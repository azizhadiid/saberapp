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

