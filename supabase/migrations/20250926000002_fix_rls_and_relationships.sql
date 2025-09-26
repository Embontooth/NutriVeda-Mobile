-- Fix RLS policies to work with Firebase Auth or disable completely
-- Drop all existing RLS policies
DROP POLICY IF EXISTS "Users can view own profile" ON public.profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON public.profiles;
DROP POLICY IF EXISTS "Users can insert own profile" ON public.profiles;
DROP POLICY IF EXISTS "Dietitians can view all patient profiles" ON public.patient_health_profiles;
DROP POLICY IF EXISTS "Patients can view own health profile" ON public.patient_health_profiles;
DROP POLICY IF EXISTS "Dietitians can manage patient health profiles" ON public.patient_health_profiles;
DROP POLICY IF EXISTS "Dietitians can create diet charts" ON public.diet_charts;
DROP POLICY IF EXISTS "Dietitians and patients can view diet charts" ON public.diet_charts;
DROP POLICY IF EXISTS "Dietitians can update diet charts" ON public.diet_charts;
DROP POLICY IF EXISTS "Dietitians can create meal plans" ON public.meal_plans;
DROP POLICY IF EXISTS "Dietitians and patients can view meal plans" ON public.meal_plans;
DROP POLICY IF EXISTS "Patients can create food logs" ON public.food_intake_logs;
DROP POLICY IF EXISTS "Patients and dietitians can view food logs" ON public.food_intake_logs;

-- Completely disable RLS for all tables to allow Firebase Auth
ALTER TABLE public.profiles DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.patient_health_profiles DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.diet_charts DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.meal_plans DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.meal_items DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.food_intake_logs DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.food_items DISABLE ROW LEVEL SECURITY;

-- Add indexes for better performance with Firebase Auth
CREATE INDEX IF NOT EXISTS idx_profiles_firebase_uid ON public.profiles(firebase_uid);
CREATE INDEX IF NOT EXISTS idx_patient_health_profiles_dietitian ON public.patient_health_profiles(dietitian_id);
CREATE INDEX IF NOT EXISTS idx_patient_health_profiles_patient ON public.patient_health_profiles(patient_id);
CREATE INDEX IF NOT EXISTS idx_diet_charts_dietitian ON public.diet_charts(dietitian_id);
CREATE INDEX IF NOT EXISTS idx_diet_charts_patient ON public.diet_charts(patient_id);
CREATE INDEX IF NOT EXISTS idx_meal_plans_chart ON public.meal_plans(diet_chart_id);
CREATE INDEX IF NOT EXISTS idx_food_logs_patient ON public.food_intake_logs(patient_id);

-- Grant full access to authenticated users (Firebase Auth via service role key)
GRANT ALL ON ALL TABLES IN SCHEMA public TO anon;
GRANT ALL ON ALL TABLES IN SCHEMA public TO authenticated;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO anon;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO authenticated;

-- Ensure all tables allow insert, update, delete, select
GRANT INSERT, UPDATE, DELETE, SELECT ON public.profiles TO anon, authenticated;
GRANT INSERT, UPDATE, DELETE, SELECT ON public.patient_health_profiles TO anon, authenticated;
GRANT INSERT, UPDATE, DELETE, SELECT ON public.diet_charts TO anon, authenticated;
GRANT INSERT, UPDATE, DELETE, SELECT ON public.meal_plans TO anon, authenticated;
GRANT INSERT, UPDATE, DELETE, SELECT ON public.meal_items TO anon, authenticated;
GRANT INSERT, UPDATE, DELETE, SELECT ON public.food_intake_logs TO anon, authenticated;
GRANT INSERT, UPDATE, DELETE, SELECT ON public.food_items TO anon, authenticated;