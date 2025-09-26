-- Temporarily disable RLS on problematic tables to allow Firebase Auth integration
-- We'll handle authorization in the application layer instead

-- Disable RLS on patient_health_profiles
ALTER TABLE "public"."patient_health_profiles" DISABLE ROW LEVEL SECURITY;

-- Disable RLS on profiles (already handled by Firebase Auth)
ALTER TABLE "public"."profiles" DISABLE ROW LEVEL SECURITY;

-- Disable RLS on diet_charts
ALTER TABLE "public"."diet_charts" DISABLE ROW LEVEL SECURITY;

-- Disable RLS on meal_plans
ALTER TABLE "public"."meal_plans" DISABLE ROW LEVEL SECURITY;

-- Disable RLS on meal_items  
ALTER TABLE "public"."meal_items" DISABLE ROW LEVEL SECURITY;

-- Disable RLS on food_intake_logs
ALTER TABLE "public"."food_intake_logs" DISABLE ROW LEVEL SECURITY;

-- Keep RLS enabled on sensitive tables but with simple policies
-- food_items can remain as is since it's reference data

-- Note: In production, you should implement proper RLS policies 
-- that work with your Firebase Auth integration