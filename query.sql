-- 1. Membuat tabel 'companies' untuk menyimpan data profil perusahaan
CREATE TABLE IF NOT EXISTS public.companies (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  siinas_id TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 2. Membuat tabel 'authorized' untuk relasi akun Google/Email ke Perusahaan
CREATE TABLE IF NOT EXISTS public.authorized (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  company_id UUID REFERENCES public.companies(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 3. Mengaktifkan Row Level Security (Keamanan Supabase)
ALTER TABLE public.companies ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.authorized ENABLE ROW LEVEL SECURITY;

-- 4. Membuat Kebijakan RLS (Policy) agar aplikasi Flutter bisa melakukan Insert dan Select
-- Kebijakan untuk tabel companies
CREATE POLICY "Enable read access for authenticated users" 
  ON public.companies FOR SELECT 
  USING (auth.role() = 'authenticated');

CREATE POLICY "Enable insert for authenticated users" 
  ON public.companies FOR INSERT 
  WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Enable update for authenticated users" 
  ON public.companies FOR UPDATE
  USING (auth.role() = 'authenticated');

-- Kebijakan untuk tabel authorized
CREATE POLICY "Enable read access for authorized users" 
  ON public.authorized FOR SELECT 
  USING (auth.uid() = user_id);

CREATE POLICY "Enable insert for authorized users" 
  ON public.authorized FOR INSERT 
  WITH CHECK (auth.uid() = user_id);

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





--   NEW DB -----------------------------------------------------------------------------
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