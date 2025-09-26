# NutriVeda Database Schema Overview

Your Supabase database contains **8 main tables** for managing a comprehensive nutrition and dietitian management system:

## 📊 **Database Tables**

### 1. **`profiles`** - User Management
- **Purpose**: Stores user information for patients, dietitians, and admins
- **Key Fields**: 
  - `id` (UUID) - Links to Supabase Auth
  - `email`, `full_name`, `role` (admin/dietitian/patient)
  - `phone`, `date_of_birth`, `gender`

### 2. **`patient_health_profiles`** - Health Assessment
- **Purpose**: Detailed health profiles with Ayurvedic dosha analysis
- **Key Fields**:
  - `patient_id`, `dietitian_id`
  - Physical: `height`, `weight`, `activity_level`
  - Ayurvedic: `prakriti_vata/pitta/kapha`, `vikriti_vata/pitta/kapha`
  - Medical: `medical_conditions[]`, `allergies[]`, `dietary_restrictions[]`
  - Lifestyle: `sleep_hours`, `stress_level`, `digestion_strength`

### 3. **`food_items`** - Food Database
- **Purpose**: Comprehensive food database with nutritional and Ayurvedic properties
- **Key Fields**:
  - Basic: `name`, `category`, `subcategory`
  - Nutrition: `calories`, `protein`, `carbohydrates`, `fat`, `fiber`, vitamins, minerals
  - Ayurvedic: `rasa[]` (tastes), `virya` (heating/cooling), `vipaka`, `dosha_effect`, `guna[]`
  - Additional: `seasonal_availability[]`, `health_benefits[]`, `contraindications[]`

### 4. **`diet_charts`** - Diet Plans
- **Purpose**: Master diet plans created by dietitians for patients
- **Key Fields**:
  - `patient_id`, `dietitian_id`, `name`, `description`
  - `start_date`, `end_date`, `status`
  - Targets: `target_calories`, `target_protein`, `target_carbs`, `target_fat`, `target_fiber`
  - Ayurvedic: `dosha_focus[]`, `seasonal_considerations`

### 5. **`meal_plans`** - Meal Structure
- **Purpose**: Defines meal structure within diet charts (breakfast, lunch, etc.)
- **Key Fields**:
  - `diet_chart_id`, `day_of_week` (1-7)
  - `meal_type` (breakfast/mid_morning/lunch/evening_snack/dinner/bedtime)
  - `meal_time`

### 6. **`meal_items`** - Meal Content
- **Purpose**: Specific food items within meal plans
- **Key Fields**:
  - `meal_plan_id`, `food_item_id`
  - `quantity`, `preparation_method`, `notes`

### 7. **`food_intake_logs`** - Patient Tracking
- **Purpose**: Track what patients actually eat
- **Key Fields**:
  - `patient_id`, `food_item_id`, `quantity`
  - `meal_type`, `consumed_at`
  - Calculated: `calories_consumed`, `protein_consumed`, etc.

### 8. **`patient_progress`** - Progress Tracking
- **Purpose**: Track patient health improvements over time
- **Key Fields**:
  - Physical: `weight`, `body_fat_percentage`, `muscle_mass`, `waist_circumference`
  - Ayurvedic: `current_vata/pitta/kapha`
  - Wellness: `energy_level`, `sleep_quality`, `digestion_quality`, `stress_level`, `mood_rating`
  - Qualitative: `symptoms[]`, `improvements[]`, `challenges[]`

## 🔐 **Security Features**

- **Row Level Security (RLS)** enabled on all tables
- **Role-based access**: Admin, Dietitian, Patient permissions
- **Automatic user profile creation** via trigger on auth signup
- **Secure relationships** with foreign key constraints

## 📈 **Key Features**

✅ **Ayurvedic Integration**: Dosha analysis, rasa, virya, vipaka tracking  
✅ **Comprehensive Nutrition**: Full macro/micronutrient tracking  
✅ **Progress Monitoring**: Weight, body composition, wellness metrics  
✅ **Diet Management**: Complete meal planning and tracking  
✅ **Multi-role Support**: Patients, dietitians, and administrators  
✅ **Seasonal Awareness**: Food availability and recommendations  

## 🔍 **Quick Queries for Testing**

```sql
-- Check total users by role
SELECT role, COUNT(*) FROM profiles GROUP BY role;

-- List all food categories
SELECT DISTINCT category FROM food_items ORDER BY category;

-- Check active diet charts
SELECT * FROM diet_charts WHERE status = 'active';

-- View recent patient progress
SELECT * FROM patient_progress ORDER BY recorded_date DESC LIMIT 10;
```

Your database is comprehensive and ready for a full-featured nutrition management application!