-- Update the current Firebase user's role to 'dietitian'
UPDATE profiles 
SET role = 'dietitian' 
WHERE firebase_uid = 'Tdg2OGFgByVlKAfOlohd3SEafud2';

-- Verify the update
SELECT id, firebase_uid, full_name, email, role 
FROM profiles 
WHERE firebase_uid = 'Tdg2OGFgByVlKAfOlohd3SEafud2';