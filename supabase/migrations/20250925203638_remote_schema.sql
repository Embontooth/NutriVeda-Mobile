


SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;


COMMENT ON SCHEMA "public" IS 'standard public schema';



CREATE EXTENSION IF NOT EXISTS "pg_graphql" WITH SCHEMA "graphql";






CREATE EXTENSION IF NOT EXISTS "pg_stat_statements" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "supabase_vault" WITH SCHEMA "vault";






CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA "extensions";






CREATE OR REPLACE FUNCTION "public"."handle_new_user"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
begin
  insert into public.profiles (id, email, full_name, role)
  values (
    new.id,
    new.email,
    coalesce(new.raw_user_meta_data ->> 'full_name', 'New User'),
    coalesce(new.raw_user_meta_data ->> 'role', 'patient')
  )
  on conflict (id) do nothing;

  return new;
end;
$$;


ALTER FUNCTION "public"."handle_new_user"() OWNER TO "postgres";

SET default_tablespace = '';

SET default_table_access_method = "heap";


CREATE TABLE IF NOT EXISTS "public"."diet_charts" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "patient_id" "uuid" NOT NULL,
    "dietitian_id" "uuid" NOT NULL,
    "name" "text" NOT NULL,
    "description" "text",
    "start_date" "date" NOT NULL,
    "end_date" "date",
    "status" "text" DEFAULT 'draft'::"text",
    "target_calories" numeric(8,2),
    "target_protein" numeric(8,2),
    "target_carbs" numeric(8,2),
    "target_fat" numeric(8,2),
    "target_fiber" numeric(8,2),
    "dosha_focus" "text"[] DEFAULT '{}'::"text"[],
    "seasonal_considerations" "text",
    "special_instructions" "text",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "diet_charts_status_check" CHECK (("status" = ANY (ARRAY['draft'::"text", 'active'::"text", 'completed'::"text", 'cancelled'::"text"])))
);


ALTER TABLE "public"."diet_charts" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."food_intake_logs" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "patient_id" "uuid" NOT NULL,
    "food_item_id" "uuid" NOT NULL,
    "quantity" numeric(8,2) NOT NULL,
    "meal_type" "text" NOT NULL,
    "consumed_at" timestamp with time zone NOT NULL,
    "calories_consumed" numeric(8,2),
    "protein_consumed" numeric(8,2),
    "carbs_consumed" numeric(8,2),
    "fat_consumed" numeric(8,2),
    "created_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "food_intake_logs_meal_type_check" CHECK (("meal_type" = ANY (ARRAY['breakfast'::"text", 'mid_morning'::"text", 'lunch'::"text", 'evening_snack'::"text", 'dinner'::"text", 'bedtime'::"text"])))
);


ALTER TABLE "public"."food_intake_logs" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."food_items" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" NOT NULL,
    "category" "text" NOT NULL,
    "subcategory" "text",
    "calories" numeric(8,2) DEFAULT 0 NOT NULL,
    "protein" numeric(8,2) DEFAULT 0 NOT NULL,
    "carbohydrates" numeric(8,2) DEFAULT 0 NOT NULL,
    "fat" numeric(8,2) DEFAULT 0 NOT NULL,
    "fiber" numeric(8,2) DEFAULT 0 NOT NULL,
    "sugar" numeric(8,2) DEFAULT 0 NOT NULL,
    "sodium" numeric(8,2) DEFAULT 0 NOT NULL,
    "potassium" numeric(8,2) DEFAULT 0 NOT NULL,
    "calcium" numeric(8,2) DEFAULT 0 NOT NULL,
    "iron" numeric(8,2) DEFAULT 0 NOT NULL,
    "vitamin_a" numeric(8,2) DEFAULT 0 NOT NULL,
    "vitamin_c" numeric(8,2) DEFAULT 0 NOT NULL,
    "vitamin_d" numeric(8,2) DEFAULT 0 NOT NULL,
    "vitamin_e" numeric(8,2) DEFAULT 0 NOT NULL,
    "vitamin_k" numeric(8,2) DEFAULT 0 NOT NULL,
    "thiamine" numeric(8,2) DEFAULT 0 NOT NULL,
    "riboflavin" numeric(8,2) DEFAULT 0 NOT NULL,
    "niacin" numeric(8,2) DEFAULT 0 NOT NULL,
    "vitamin_b6" numeric(8,2) DEFAULT 0 NOT NULL,
    "folate" numeric(8,2) DEFAULT 0 NOT NULL,
    "vitamin_b12" numeric(8,2) DEFAULT 0 NOT NULL,
    "rasa" "text"[] DEFAULT '{}'::"text"[],
    "virya" "text",
    "vipaka" "text",
    "dosha_effect" "jsonb" DEFAULT '{}'::"jsonb",
    "guna" "text"[] DEFAULT '{}'::"text"[],
    "seasonal_availability" "text"[] DEFAULT '{}'::"text"[],
    "preparation_methods" "text"[] DEFAULT '{}'::"text"[],
    "contraindications" "text"[] DEFAULT '{}'::"text"[],
    "health_benefits" "text"[] DEFAULT '{}'::"text"[],
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "food_items_vipaka_check" CHECK (("vipaka" = ANY (ARRAY['sweet'::"text", 'sour'::"text", 'pungent'::"text"]))),
    CONSTRAINT "food_items_virya_check" CHECK (("virya" = ANY (ARRAY['heating'::"text", 'cooling'::"text"])))
);


ALTER TABLE "public"."food_items" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."meal_items" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "meal_plan_id" "uuid" NOT NULL,
    "food_item_id" "uuid" NOT NULL,
    "quantity" numeric(8,2) NOT NULL,
    "preparation_method" "text",
    "notes" "text",
    "created_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."meal_items" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."meal_plans" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "diet_chart_id" "uuid" NOT NULL,
    "day_of_week" integer,
    "meal_type" "text" NOT NULL,
    "meal_time" time without time zone,
    "created_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "meal_plans_day_of_week_check" CHECK ((("day_of_week" >= 1) AND ("day_of_week" <= 7))),
    CONSTRAINT "meal_plans_meal_type_check" CHECK (("meal_type" = ANY (ARRAY['breakfast'::"text", 'mid_morning'::"text", 'lunch'::"text", 'evening_snack'::"text", 'dinner'::"text", 'bedtime'::"text"])))
);


ALTER TABLE "public"."meal_plans" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."patient_health_profiles" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "patient_id" "uuid" NOT NULL,
    "dietitian_id" "uuid",
    "height" numeric(5,2),
    "weight" numeric(5,2),
    "activity_level" "text",
    "prakriti_vata" numeric(3,1) DEFAULT 0,
    "prakriti_pitta" numeric(3,1) DEFAULT 0,
    "prakriti_kapha" numeric(3,1) DEFAULT 0,
    "vikriti_vata" numeric(3,1) DEFAULT 0,
    "vikriti_pitta" numeric(3,1) DEFAULT 0,
    "vikriti_kapha" numeric(3,1) DEFAULT 0,
    "medical_conditions" "text"[] DEFAULT '{}'::"text"[],
    "allergies" "text"[] DEFAULT '{}'::"text"[],
    "dietary_restrictions" "text"[] DEFAULT '{}'::"text"[],
    "health_goals" "text"[] DEFAULT '{}'::"text"[],
    "sleep_hours" numeric(3,1),
    "stress_level" numeric(2,1),
    "digestion_strength" "text",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "patient_health_profiles_activity_level_check" CHECK (("activity_level" = ANY (ARRAY['sedentary'::"text", 'lightly_active'::"text", 'moderately_active'::"text", 'very_active'::"text", 'extremely_active'::"text"]))),
    CONSTRAINT "patient_health_profiles_digestion_strength_check" CHECK (("digestion_strength" = ANY (ARRAY['weak'::"text", 'moderate'::"text", 'strong'::"text"]))),
    CONSTRAINT "patient_health_profiles_prakriti_kapha_check" CHECK ((("prakriti_kapha" >= (0)::numeric) AND ("prakriti_kapha" <= (10)::numeric))),
    CONSTRAINT "patient_health_profiles_prakriti_pitta_check" CHECK ((("prakriti_pitta" >= (0)::numeric) AND ("prakriti_pitta" <= (10)::numeric))),
    CONSTRAINT "patient_health_profiles_prakriti_vata_check" CHECK ((("prakriti_vata" >= (0)::numeric) AND ("prakriti_vata" <= (10)::numeric))),
    CONSTRAINT "patient_health_profiles_stress_level_check" CHECK ((("stress_level" >= (1)::numeric) AND ("stress_level" <= (10)::numeric))),
    CONSTRAINT "patient_health_profiles_vikriti_kapha_check" CHECK ((("vikriti_kapha" >= (0)::numeric) AND ("vikriti_kapha" <= (10)::numeric))),
    CONSTRAINT "patient_health_profiles_vikriti_pitta_check" CHECK ((("vikriti_pitta" >= (0)::numeric) AND ("vikriti_pitta" <= (10)::numeric))),
    CONSTRAINT "patient_health_profiles_vikriti_vata_check" CHECK ((("vikriti_vata" >= (0)::numeric) AND ("vikriti_vata" <= (10)::numeric)))
);


ALTER TABLE "public"."patient_health_profiles" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."patient_progress" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "patient_id" "uuid" NOT NULL,
    "diet_chart_id" "uuid",
    "weight" numeric(5,2),
    "body_fat_percentage" numeric(4,2),
    "muscle_mass" numeric(5,2),
    "waist_circumference" numeric(5,2),
    "current_vata" numeric(3,1),
    "current_pitta" numeric(3,1),
    "current_kapha" numeric(3,1),
    "energy_level" numeric(2,1),
    "sleep_quality" numeric(2,1),
    "digestion_quality" numeric(2,1),
    "stress_level" numeric(2,1),
    "mood_rating" numeric(2,1),
    "symptoms" "text"[] DEFAULT '{}'::"text"[],
    "improvements" "text"[] DEFAULT '{}'::"text"[],
    "challenges" "text"[] DEFAULT '{}'::"text"[],
    "notes" "text",
    "recorded_date" "date" DEFAULT CURRENT_DATE NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "patient_progress_current_kapha_check" CHECK ((("current_kapha" >= (0)::numeric) AND ("current_kapha" <= (10)::numeric))),
    CONSTRAINT "patient_progress_current_pitta_check" CHECK ((("current_pitta" >= (0)::numeric) AND ("current_pitta" <= (10)::numeric))),
    CONSTRAINT "patient_progress_current_vata_check" CHECK ((("current_vata" >= (0)::numeric) AND ("current_vata" <= (10)::numeric))),
    CONSTRAINT "patient_progress_digestion_quality_check" CHECK ((("digestion_quality" >= (1)::numeric) AND ("digestion_quality" <= (10)::numeric))),
    CONSTRAINT "patient_progress_energy_level_check" CHECK ((("energy_level" >= (1)::numeric) AND ("energy_level" <= (10)::numeric))),
    CONSTRAINT "patient_progress_mood_rating_check" CHECK ((("mood_rating" >= (1)::numeric) AND ("mood_rating" <= (10)::numeric))),
    CONSTRAINT "patient_progress_sleep_quality_check" CHECK ((("sleep_quality" >= (1)::numeric) AND ("sleep_quality" <= (10)::numeric))),
    CONSTRAINT "patient_progress_stress_level_check" CHECK ((("stress_level" >= (1)::numeric) AND ("stress_level" <= (10)::numeric)))
);


ALTER TABLE "public"."patient_progress" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."profiles" (
    "id" "uuid" NOT NULL,
    "email" "text" NOT NULL,
    "full_name" "text" NOT NULL,
    "role" "text" DEFAULT 'patient'::"text" NOT NULL,
    "phone" "text",
    "date_of_birth" "date",
    "gender" "text",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "profiles_gender_check" CHECK (("gender" = ANY (ARRAY['male'::"text", 'female'::"text", 'other'::"text"]))),
    CONSTRAINT "profiles_role_check" CHECK (("role" = ANY (ARRAY['admin'::"text", 'dietitian'::"text", 'patient'::"text"])))
);


ALTER TABLE "public"."profiles" OWNER TO "postgres";


ALTER TABLE ONLY "public"."diet_charts"
    ADD CONSTRAINT "diet_charts_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."food_intake_logs"
    ADD CONSTRAINT "food_intake_logs_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."food_items"
    ADD CONSTRAINT "food_items_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."meal_items"
    ADD CONSTRAINT "meal_items_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."meal_plans"
    ADD CONSTRAINT "meal_plans_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."patient_health_profiles"
    ADD CONSTRAINT "patient_health_profiles_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."patient_progress"
    ADD CONSTRAINT "patient_progress_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "profiles_pkey" PRIMARY KEY ("id");



CREATE INDEX "idx_food_intake_logs_patient_date" ON "public"."food_intake_logs" USING "btree" ("patient_id", "consumed_at");



CREATE INDEX "idx_food_items_category" ON "public"."food_items" USING "btree" ("category");



CREATE INDEX "idx_food_items_name" ON "public"."food_items" USING "gin" ("to_tsvector"('"english"'::"regconfig", "name"));



CREATE INDEX "idx_food_items_rasa" ON "public"."food_items" USING "gin" ("rasa");



CREATE INDEX "idx_patient_progress_patient_date" ON "public"."patient_progress" USING "btree" ("patient_id", "recorded_date");



ALTER TABLE ONLY "public"."diet_charts"
    ADD CONSTRAINT "diet_charts_dietitian_id_fkey" FOREIGN KEY ("dietitian_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."diet_charts"
    ADD CONSTRAINT "diet_charts_patient_id_fkey" FOREIGN KEY ("patient_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."food_intake_logs"
    ADD CONSTRAINT "food_intake_logs_food_item_id_fkey" FOREIGN KEY ("food_item_id") REFERENCES "public"."food_items"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."food_intake_logs"
    ADD CONSTRAINT "food_intake_logs_patient_id_fkey" FOREIGN KEY ("patient_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."meal_items"
    ADD CONSTRAINT "meal_items_food_item_id_fkey" FOREIGN KEY ("food_item_id") REFERENCES "public"."food_items"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."meal_items"
    ADD CONSTRAINT "meal_items_meal_plan_id_fkey" FOREIGN KEY ("meal_plan_id") REFERENCES "public"."meal_plans"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."meal_plans"
    ADD CONSTRAINT "meal_plans_diet_chart_id_fkey" FOREIGN KEY ("diet_chart_id") REFERENCES "public"."diet_charts"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."patient_health_profiles"
    ADD CONSTRAINT "patient_health_profiles_dietitian_id_fkey" FOREIGN KEY ("dietitian_id") REFERENCES "public"."profiles"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."patient_health_profiles"
    ADD CONSTRAINT "patient_health_profiles_patient_id_fkey" FOREIGN KEY ("patient_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."patient_progress"
    ADD CONSTRAINT "patient_progress_diet_chart_id_fkey" FOREIGN KEY ("diet_chart_id") REFERENCES "public"."diet_charts"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."patient_progress"
    ADD CONSTRAINT "patient_progress_patient_id_fkey" FOREIGN KEY ("patient_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "profiles_id_fkey" FOREIGN KEY ("id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE "public"."diet_charts" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "diet_charts_insert_dietitian_admin" ON "public"."diet_charts" FOR INSERT WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."profiles" "p"
  WHERE (("p"."id" = "auth"."uid"()) AND ("p"."role" = ANY (ARRAY['admin'::"text", 'dietitian'::"text"]))))));



CREATE POLICY "diet_charts_select_own_or_dietitian" ON "public"."diet_charts" FOR SELECT USING ((("patient_id" = "auth"."uid"()) OR ("dietitian_id" = "auth"."uid"()) OR (EXISTS ( SELECT 1
   FROM "public"."profiles" "p"
  WHERE (("p"."id" = "auth"."uid"()) AND ("p"."role" = 'admin'::"text"))))));



CREATE POLICY "diet_charts_update_dietitian_admin" ON "public"."diet_charts" FOR UPDATE USING ((("dietitian_id" = "auth"."uid"()) OR (EXISTS ( SELECT 1
   FROM "public"."profiles" "p"
  WHERE (("p"."id" = "auth"."uid"()) AND ("p"."role" = 'admin'::"text"))))));



ALTER TABLE "public"."food_intake_logs" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "food_intake_logs_insert_own" ON "public"."food_intake_logs" FOR INSERT WITH CHECK (("patient_id" = "auth"."uid"()));



CREATE POLICY "food_intake_logs_select_own_or_dietitian" ON "public"."food_intake_logs" FOR SELECT USING ((("patient_id" = "auth"."uid"()) OR (EXISTS ( SELECT 1
   FROM "public"."patient_health_profiles" "php"
  WHERE (("php"."patient_id" = "food_intake_logs"."patient_id") AND ("php"."dietitian_id" = "auth"."uid"())))) OR (EXISTS ( SELECT 1
   FROM "public"."profiles" "p"
  WHERE (("p"."id" = "auth"."uid"()) AND ("p"."role" = 'admin'::"text"))))));



ALTER TABLE "public"."food_items" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "food_items_delete_admin_only" ON "public"."food_items" FOR DELETE USING ((EXISTS ( SELECT 1
   FROM "public"."profiles" "p"
  WHERE (("p"."id" = "auth"."uid"()) AND ("p"."role" = 'admin'::"text")))));



CREATE POLICY "food_items_insert_admin_dietitian" ON "public"."food_items" FOR INSERT WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."profiles" "p"
  WHERE (("p"."id" = "auth"."uid"()) AND ("p"."role" = ANY (ARRAY['admin'::"text", 'dietitian'::"text"]))))));



CREATE POLICY "food_items_select_all" ON "public"."food_items" FOR SELECT USING (true);



CREATE POLICY "food_items_update_admin_dietitian" ON "public"."food_items" FOR UPDATE USING ((EXISTS ( SELECT 1
   FROM "public"."profiles" "p"
  WHERE (("p"."id" = "auth"."uid"()) AND ("p"."role" = ANY (ARRAY['admin'::"text", 'dietitian'::"text"]))))));



ALTER TABLE "public"."meal_items" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "meal_items_insert_dietitian_admin" ON "public"."meal_items" FOR INSERT WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."profiles" "p"
  WHERE (("p"."id" = "auth"."uid"()) AND ("p"."role" = ANY (ARRAY['admin'::"text", 'dietitian'::"text"]))))));



CREATE POLICY "meal_items_select_via_meal_plan" ON "public"."meal_items" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM ("public"."meal_plans" "mp"
     JOIN "public"."diet_charts" "dc" ON (("dc"."id" = "mp"."diet_chart_id")))
  WHERE (("mp"."id" = "meal_items"."meal_plan_id") AND (("dc"."patient_id" = "auth"."uid"()) OR ("dc"."dietitian_id" = "auth"."uid"()) OR (EXISTS ( SELECT 1
           FROM "public"."profiles" "p"
          WHERE (("p"."id" = "auth"."uid"()) AND ("p"."role" = 'admin'::"text")))))))));



CREATE POLICY "meal_items_update_dietitian_admin" ON "public"."meal_items" FOR UPDATE USING ((EXISTS ( SELECT 1
   FROM "public"."profiles" "p"
  WHERE (("p"."id" = "auth"."uid"()) AND ("p"."role" = ANY (ARRAY['admin'::"text", 'dietitian'::"text"]))))));



ALTER TABLE "public"."meal_plans" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "meal_plans_insert_dietitian_admin" ON "public"."meal_plans" FOR INSERT WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."profiles" "p"
  WHERE (("p"."id" = "auth"."uid"()) AND ("p"."role" = ANY (ARRAY['admin'::"text", 'dietitian'::"text"]))))));



CREATE POLICY "meal_plans_select_via_diet_chart" ON "public"."meal_plans" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM "public"."diet_charts" "dc"
  WHERE (("dc"."id" = "meal_plans"."diet_chart_id") AND (("dc"."patient_id" = "auth"."uid"()) OR ("dc"."dietitian_id" = "auth"."uid"()) OR (EXISTS ( SELECT 1
           FROM "public"."profiles" "p"
          WHERE (("p"."id" = "auth"."uid"()) AND ("p"."role" = 'admin'::"text")))))))));



CREATE POLICY "meal_plans_update_dietitian_admin" ON "public"."meal_plans" FOR UPDATE USING ((EXISTS ( SELECT 1
   FROM "public"."profiles" "p"
  WHERE (("p"."id" = "auth"."uid"()) AND ("p"."role" = ANY (ARRAY['admin'::"text", 'dietitian'::"text"]))))));



ALTER TABLE "public"."patient_health_profiles" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "patient_health_profiles_insert_own_or_dietitian" ON "public"."patient_health_profiles" FOR INSERT WITH CHECK ((("patient_id" = "auth"."uid"()) OR (EXISTS ( SELECT 1
   FROM "public"."profiles" "p"
  WHERE (("p"."id" = "auth"."uid"()) AND ("p"."role" = ANY (ARRAY['admin'::"text", 'dietitian'::"text"])))))));



CREATE POLICY "patient_health_profiles_select_own_or_dietitian" ON "public"."patient_health_profiles" FOR SELECT USING ((("patient_id" = "auth"."uid"()) OR ("dietitian_id" = "auth"."uid"()) OR (EXISTS ( SELECT 1
   FROM "public"."profiles" "p"
  WHERE (("p"."id" = "auth"."uid"()) AND ("p"."role" = 'admin'::"text"))))));



CREATE POLICY "patient_health_profiles_update_own_or_dietitian" ON "public"."patient_health_profiles" FOR UPDATE USING ((("patient_id" = "auth"."uid"()) OR ("dietitian_id" = "auth"."uid"()) OR (EXISTS ( SELECT 1
   FROM "public"."profiles" "p"
  WHERE (("p"."id" = "auth"."uid"()) AND ("p"."role" = 'admin'::"text"))))));



ALTER TABLE "public"."patient_progress" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "patient_progress_insert_own_or_dietitian" ON "public"."patient_progress" FOR INSERT WITH CHECK ((("patient_id" = "auth"."uid"()) OR (EXISTS ( SELECT 1
   FROM "public"."profiles" "p"
  WHERE (("p"."id" = "auth"."uid"()) AND ("p"."role" = ANY (ARRAY['admin'::"text", 'dietitian'::"text"])))))));



CREATE POLICY "patient_progress_select_own_or_dietitian" ON "public"."patient_progress" FOR SELECT USING ((("patient_id" = "auth"."uid"()) OR (EXISTS ( SELECT 1
   FROM "public"."patient_health_profiles" "php"
  WHERE (("php"."patient_id" = "patient_progress"."patient_id") AND ("php"."dietitian_id" = "auth"."uid"())))) OR (EXISTS ( SELECT 1
   FROM "public"."profiles" "p"
  WHERE (("p"."id" = "auth"."uid"()) AND ("p"."role" = 'admin'::"text"))))));



ALTER TABLE "public"."profiles" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "profiles_delete_admin_only" ON "public"."profiles" FOR DELETE USING ((EXISTS ( SELECT 1
   FROM "public"."profiles" "p"
  WHERE (("p"."id" = "auth"."uid"()) AND ("p"."role" = 'admin'::"text")))));



CREATE POLICY "profiles_insert_own" ON "public"."profiles" FOR INSERT WITH CHECK (("auth"."uid"() = "id"));



CREATE POLICY "profiles_select_own_or_dietitian" ON "public"."profiles" FOR SELECT USING ((("auth"."uid"() = "id") OR (EXISTS ( SELECT 1
   FROM "public"."profiles" "p"
  WHERE (("p"."id" = "auth"."uid"()) AND ("p"."role" = ANY (ARRAY['admin'::"text", 'dietitian'::"text"])))))));



CREATE POLICY "profiles_update_own_or_admin" ON "public"."profiles" FOR UPDATE USING ((("auth"."uid"() = "id") OR (EXISTS ( SELECT 1
   FROM "public"."profiles" "p"
  WHERE (("p"."id" = "auth"."uid"()) AND ("p"."role" = 'admin'::"text"))))));





ALTER PUBLICATION "supabase_realtime" OWNER TO "postgres";


GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";

























































































































































GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "anon";
GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "service_role";


















GRANT ALL ON TABLE "public"."diet_charts" TO "anon";
GRANT ALL ON TABLE "public"."diet_charts" TO "authenticated";
GRANT ALL ON TABLE "public"."diet_charts" TO "service_role";



GRANT ALL ON TABLE "public"."food_intake_logs" TO "anon";
GRANT ALL ON TABLE "public"."food_intake_logs" TO "authenticated";
GRANT ALL ON TABLE "public"."food_intake_logs" TO "service_role";



GRANT ALL ON TABLE "public"."food_items" TO "anon";
GRANT ALL ON TABLE "public"."food_items" TO "authenticated";
GRANT ALL ON TABLE "public"."food_items" TO "service_role";



GRANT ALL ON TABLE "public"."meal_items" TO "anon";
GRANT ALL ON TABLE "public"."meal_items" TO "authenticated";
GRANT ALL ON TABLE "public"."meal_items" TO "service_role";



GRANT ALL ON TABLE "public"."meal_plans" TO "anon";
GRANT ALL ON TABLE "public"."meal_plans" TO "authenticated";
GRANT ALL ON TABLE "public"."meal_plans" TO "service_role";



GRANT ALL ON TABLE "public"."patient_health_profiles" TO "anon";
GRANT ALL ON TABLE "public"."patient_health_profiles" TO "authenticated";
GRANT ALL ON TABLE "public"."patient_health_profiles" TO "service_role";



GRANT ALL ON TABLE "public"."patient_progress" TO "anon";
GRANT ALL ON TABLE "public"."patient_progress" TO "authenticated";
GRANT ALL ON TABLE "public"."patient_progress" TO "service_role";



GRANT ALL ON TABLE "public"."profiles" TO "anon";
GRANT ALL ON TABLE "public"."profiles" TO "authenticated";
GRANT ALL ON TABLE "public"."profiles" TO "service_role";









ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "service_role";































RESET ALL;
CREATE TRIGGER on_auth_user_created AFTER INSERT ON auth.users FOR EACH ROW EXECUTE FUNCTION handle_new_user();


