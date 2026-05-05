-- ============================================================
-- MacroLog — Supabase Schema
-- Paste this into the Supabase SQL Editor and click "Run"
-- ============================================================


-- ============================================================
-- 1. PROFILES
--    Extends the built-in auth.users table with display info.
--    A row is created automatically when a user signs up.
-- ============================================================

CREATE TABLE IF NOT EXISTS public.profiles (
  id          UUID PRIMARY KEY REFERENCES auth.users (id) ON DELETE CASCADE,
  username    TEXT,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Auto-create a profile row when a new user signs up
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER SET search_path = public
AS $$
BEGIN
  INSERT INTO public.profiles (id)
  VALUES (NEW.id)
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();


-- ============================================================
-- 2. MACRO TARGETS
--    Daily nutrition goals per user.
--    Users can update these at any time.
-- ============================================================

CREATE TABLE IF NOT EXISTS public.macro_targets (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id      UUID NOT NULL REFERENCES public.profiles (id) ON DELETE CASCADE,
  protein_g    NUMERIC(6,1) NOT NULL DEFAULT 160,
  carbs_g      NUMERIC(6,1) NOT NULL DEFAULT 200,
  fats_g       NUMERIC(6,1) NOT NULL DEFAULT 65,
  calories     INTEGER       NOT NULL DEFAULT 2000,
  water_ml     INTEGER       NOT NULL DEFAULT 2500,
  created_at   TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
  updated_at   TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
  CONSTRAINT positive_targets CHECK (
    protein_g  >= 0 AND
    carbs_g    >= 0 AND
    fats_g     >= 0 AND
    calories   >= 0 AND
    water_ml   >= 0
  )
);

-- Only one active target row per user
CREATE UNIQUE INDEX IF NOT EXISTS macro_targets_user_idx
  ON public.macro_targets (user_id);


-- ============================================================
-- 3. MEAL LOGS
--    One row per logged meal. Tied to a specific date so you
--    can query "all meals on 2026-04-22" easily.
-- ============================================================

CREATE TABLE IF NOT EXISTS public.meal_logs (
  id           UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id      UUID        NOT NULL REFERENCES public.profiles (id) ON DELETE CASCADE,
  meal_name    TEXT        NOT NULL DEFAULT 'Unnamed Meal',
  protein_g    NUMERIC(6,1) NOT NULL DEFAULT 0,
  carbs_g      NUMERIC(6,1) NOT NULL DEFAULT 0,
  fats_g       NUMERIC(6,1) NOT NULL DEFAULT 0,
  calories     INTEGER      NOT NULL DEFAULT 0,
  logged_date  DATE         NOT NULL DEFAULT CURRENT_DATE,
  logged_at    TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
  CONSTRAINT positive_macros CHECK (
    protein_g >= 0 AND
    carbs_g   >= 0 AND
    fats_g    >= 0 AND
    calories  >= 0
  )
);

CREATE INDEX IF NOT EXISTS meal_logs_user_date_idx
  ON public.meal_logs (user_id, logged_date DESC);


-- ============================================================
-- 4. WATER LOGS
--    Each button press or custom entry creates one row.
--    Sum amount_ml for a given user + date = daily total.
-- ============================================================

CREATE TABLE IF NOT EXISTS public.water_logs (
  id           UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id      UUID        NOT NULL REFERENCES public.profiles (id) ON DELETE CASCADE,
  amount_ml    INTEGER     NOT NULL,
  logged_date  DATE        NOT NULL DEFAULT CURRENT_DATE,
  logged_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT positive_water CHECK (amount_ml > 0)
);

CREATE INDEX IF NOT EXISTS water_logs_user_date_idx
  ON public.water_logs (user_id, logged_date DESC);


-- ============================================================
-- 5. DAILY SUMMARY VIEW
--    Handy view that aggregates totals per user per day.
--    Query: SELECT * FROM daily_summary WHERE user_id = '...'
-- ============================================================

CREATE OR REPLACE VIEW public.daily_summary AS
SELECT
  ml.user_id,
  ml.logged_date,
  ROUND(SUM(ml.protein_g), 1)  AS total_protein_g,
  ROUND(SUM(ml.carbs_g),   1)  AS total_carbs_g,
  ROUND(SUM(ml.fats_g),    1)  AS total_fats_g,
  SUM(ml.calories)             AS total_calories,
  COALESCE(wl.total_water_ml, 0) AS total_water_ml,
  COUNT(ml.id)                 AS meal_count
FROM public.meal_logs ml
LEFT JOIN (
  SELECT user_id, logged_date, SUM(amount_ml) AS total_water_ml
  FROM public.water_logs
  GROUP BY user_id, logged_date
) wl ON wl.user_id = ml.user_id AND wl.logged_date = ml.logged_date
GROUP BY ml.user_id, ml.logged_date, wl.total_water_ml;


-- ============================================================
-- 6. ROW LEVEL SECURITY (RLS)
--    Each user can only read and write their own rows.
--    This is enforced at the database level — not just the app.
-- ============================================================

ALTER TABLE public.profiles     ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.macro_targets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.meal_logs     ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.water_logs    ENABLE ROW LEVEL SECURITY;

-- Profiles
CREATE POLICY "Users can view own profile"
  ON public.profiles FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Users can update own profile"
  ON public.profiles FOR UPDATE
  USING (auth.uid() = id);

-- Macro Targets
CREATE POLICY "Users can view own targets"
  ON public.macro_targets FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own targets"
  ON public.macro_targets FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own targets"
  ON public.macro_targets FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own targets"
  ON public.macro_targets FOR DELETE
  USING (auth.uid() = user_id);

-- Meal Logs
CREATE POLICY "Users can view own meals"
  ON public.meal_logs FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own meals"
  ON public.meal_logs FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own meals"
  ON public.meal_logs FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own meals"
  ON public.meal_logs FOR DELETE
  USING (auth.uid() = user_id);

-- Water Logs
CREATE POLICY "Users can view own water logs"
  ON public.water_logs FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own water logs"
  ON public.water_logs FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own water logs"
  ON public.water_logs FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own water logs"
  ON public.water_logs FOR DELETE
  USING (auth.uid() = user_id);


-- ============================================================
-- EXAMPLE QUERIES (for reference — do not run as setup)
-- ============================================================

-- Log a meal:
-- INSERT INTO public.meal_logs (user_id, meal_name, protein_g, carbs_g, fats_g, calories)
-- VALUES (auth.uid(), 'Chicken & Rice', 42, 58, 8.5, 476);

-- Log water:
-- INSERT INTO public.water_logs (user_id, amount_ml)
-- VALUES (auth.uid(), 500);

-- Get today's dashboard totals:
-- SELECT * FROM public.daily_summary
-- WHERE user_id = auth.uid() AND logged_date = CURRENT_DATE;

-- Get full meal history (last 30 days):
-- SELECT * FROM public.meal_logs
-- WHERE user_id = auth.uid()
--   AND logged_date >= CURRENT_DATE - INTERVAL '30 days'
-- ORDER BY logged_at DESC;
