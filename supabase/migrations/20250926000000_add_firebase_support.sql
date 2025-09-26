-- Add firebase_uid column to profiles table for Firebase Auth integration
ALTER TABLE public.profiles 
ADD COLUMN IF NOT EXISTS firebase_uid TEXT UNIQUE;

-- Create index for faster lookups by firebase_uid
CREATE INDEX IF NOT EXISTS idx_profiles_firebase_uid 
ON public.profiles(firebase_uid);

-- Update RLS policies to be more permissive since we'll handle auth in app layer
DROP POLICY IF EXISTS profiles_select_own_or_dietitian ON public.profiles;
DROP POLICY IF EXISTS profiles_insert_own ON public.profiles;
DROP POLICY IF EXISTS profiles_update_own_or_admin ON public.profiles;
DROP POLICY IF EXISTS profiles_delete_admin_only ON public.profiles;

-- Create simplified policies for Firebase Auth integration
CREATE POLICY profiles_select_all ON public.profiles 
FOR SELECT USING (true);

CREATE POLICY profiles_insert_all ON public.profiles 
FOR INSERT WITH CHECK (true);

CREATE POLICY profiles_update_all ON public.profiles 
FOR UPDATE USING (true);

CREATE POLICY profiles_delete_admin ON public.profiles 
FOR DELETE USING (role = 'admin');