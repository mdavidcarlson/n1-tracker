-- ============================================================================
-- RECALIBRATE - SUPABASE DATABASE SCHEMA
-- ============================================================================
-- This schema supports cross-device sync for the Recalibrate health tracker
--
-- Architecture:
-- - Uses Supabase Auth for user management
-- - Row Level Security (RLS) ensures users only see their own data
-- - JSONB for flexible config storage (experiment, sliders, fields)
-- - Timestamped for sync conflict resolution
-- ============================================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================================
-- USER CONFIG TABLE
-- ============================================================================
-- Stores the tracker configuration (sliders, symptoms, experiment settings)
-- One config per user, updated when user customizes their tracker
-- ============================================================================

CREATE TABLE user_config (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  version INTEGER NOT NULL DEFAULT 3,
  title TEXT NOT NULL DEFAULT 'Recalibrate',

  -- Experiment configuration
  experiment JSONB NOT NULL DEFAULT '{
    "enabled": true,
    "startDate": "2026-01-06",
    "endDate": "2026-04-05",
    "goal": "90-Day Carnivore Reset",
    "chapters": [
      {"name": "Orientation", "endDay": 7, "color": "#2DD4BF", "message": "Getting oriented to the signals"},
      {"name": "Stabilizing", "endDay": 21, "color": "#2DD4BF", "message": "Stabilizing baseline signals"},
      {"name": "Adapting", "endDay": 42, "color": "#2DD4BF", "message": "Deep adaptation underway"},
      {"name": "Living", "endDay": 999, "color": "#2DD4BF", "message": "Living with clarity"}
    ],
    "milestones": [
      {"date": "2026-01-06", "label": "HTMA Test #1"},
      {"date": "2026-02-17", "label": "Day 42 Check"}
    ]
  }'::jsonb,

  -- Sliders configuration
  sliders JSONB NOT NULL DEFAULT '[
    {"id": "mental_clarity", "label": "Mental Clarity", "left": "Brain fog", "right": "Clear-headed", "min": -3, "max": 3},
    {"id": "craving_noise", "label": "Craving Noise", "left": "Sweet seeking", "right": "Satiated", "min": -3, "max": 3},
    {"id": "sleep_waking_state", "label": "Sleep (Waking State)", "left": "Wake by snooze", "right": "Ready to start", "min": -3, "max": 3},
    {"id": "gut_state", "label": "Gut State", "left": "Bloated and slow", "right": "Light and clean", "min": -3, "max": 3},
    {"id": "energy_stability", "label": "Energy Stability", "left": "Crashing / wired-tired", "right": "Steady all day", "min": -3, "max": 3},
    {"id": "body_comfort", "label": "Body Comfort", "left": "Stiff and creaky", "right": "Easy to live in", "min": -3, "max": 3},
    {"id": "mood_stability", "label": "Mood Stability", "left": "Reactive", "right": "Grounded", "min": -3, "max": 3}
  ]'::jsonb,

  -- Additional fields/symptoms configuration
  fields JSONB NOT NULL DEFAULT '[
    {"id": "cramps", "label": "Muscle Cramps", "type": "select", "options": ["—", "None", "Mild", "Wakes-me-up"]},
    {"id": "palps", "label": "Palpitations", "type": "select", "options": ["—", "None", "Mild", "Concerning"]}
  ]'::jsonb,

  -- Default context values
  context JSONB NOT NULL DEFAULT '{
    "electrolytes_taken": false,
    "movement_load": "none",
    "stress_load": "none"
  }'::jsonb,

  -- Sync metadata
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

  -- Ensure one config per user
  UNIQUE(user_id)
);

-- Index for fast user lookups
CREATE INDEX idx_user_config_user_id ON user_config(user_id);

-- ============================================================================
-- DAILY ENTRIES TABLE
-- ============================================================================
-- Stores daily health tracking entries
-- Each row represents one day's data for one user
-- ============================================================================

CREATE TABLE daily_entries (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,

  -- Core entry data
  date DATE NOT NULL,
  day TEXT, -- Experiment day number (optional)
  influence_note TEXT,

  -- Slider values (stored as JSONB for flexibility)
  -- Each key is a slider_id, value is -3 to 3 or null
  -- Example: {"mental_clarity": 2, "craving_noise": -1, "sleep_waking_state": null}
  slider_values JSONB NOT NULL DEFAULT '{}'::jsonb,

  -- Context values
  electrolytes_taken BOOLEAN DEFAULT false,
  breathwork_taken BOOLEAN DEFAULT false,
  gut_support_taken BOOLEAN DEFAULT false,
  gut_support_detail TEXT,
  movement_load TEXT,
  stress_load TEXT,
  offnote TEXT,
  ketones TEXT,

  -- Symptoms (stored as JSONB for flexibility)
  -- Example: {"cramps": "None", "palps": "Mild", "headache": "Concerning"}
  symptoms JSONB NOT NULL DEFAULT '{}'::jsonb,

  -- Symptom context notes (stored as JSONB)
  -- Example: {"cramps-context": "After long run", "palps-context": "Morning only"}
  symptom_contexts JSONB NOT NULL DEFAULT '{}'::jsonb,

  -- Additional custom fields (for future extensibility)
  custom_fields JSONB NOT NULL DEFAULT '{}'::jsonb,

  -- Sync metadata
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

  -- Ensure one entry per user per date
  UNIQUE(user_id, date)
);

-- Indexes for fast queries
CREATE INDEX idx_daily_entries_user_id ON daily_entries(user_id);
CREATE INDEX idx_daily_entries_date ON daily_entries(date);
CREATE INDEX idx_daily_entries_user_date ON daily_entries(user_id, date);

-- ============================================================================
-- USER PREFERENCES TABLE
-- ============================================================================
-- Stores UI preferences (dark mode, etc.)
-- ============================================================================

CREATE TABLE user_preferences (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,

  -- UI preferences
  dark_mode BOOLEAN DEFAULT false,
  last_export_date TIMESTAMP WITH TIME ZONE,

  -- Additional preferences (for future extensibility)
  preferences JSONB NOT NULL DEFAULT '{}'::jsonb,

  -- Sync metadata
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

  -- Ensure one preferences row per user
  UNIQUE(user_id)
);

-- Index for fast user lookups
CREATE INDEX idx_user_preferences_user_id ON user_preferences(user_id);

-- ============================================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- ============================================================================
-- Ensures users can only access their own data
-- ============================================================================

-- Enable RLS on all tables
ALTER TABLE user_config ENABLE ROW LEVEL SECURITY;
ALTER TABLE daily_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_preferences ENABLE ROW LEVEL SECURITY;

-- User Config Policies
CREATE POLICY "Users can view their own config"
  ON user_config FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own config"
  ON user_config FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own config"
  ON user_config FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own config"
  ON user_config FOR DELETE
  USING (auth.uid() = user_id);

-- Daily Entries Policies
CREATE POLICY "Users can view their own entries"
  ON daily_entries FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own entries"
  ON daily_entries FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own entries"
  ON daily_entries FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own entries"
  ON daily_entries FOR DELETE
  USING (auth.uid() = user_id);

-- User Preferences Policies
CREATE POLICY "Users can view their own preferences"
  ON user_preferences FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own preferences"
  ON user_preferences FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own preferences"
  ON user_preferences FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own preferences"
  ON user_preferences FOR DELETE
  USING (auth.uid() = user_id);

-- ============================================================================
-- UPDATED_AT TRIGGER
-- ============================================================================
-- Automatically update updated_at timestamp on row changes
-- ============================================================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_user_config_updated_at
  BEFORE UPDATE ON user_config
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_daily_entries_updated_at
  BEFORE UPDATE ON daily_entries
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_preferences_updated_at
  BEFORE UPDATE ON user_preferences
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- HELPER FUNCTIONS
-- ============================================================================

-- Function to get entries for a date range
CREATE OR REPLACE FUNCTION get_entries_for_date_range(
  start_date DATE,
  end_date DATE
)
RETURNS SETOF daily_entries AS $$
BEGIN
  RETURN QUERY
  SELECT * FROM daily_entries
  WHERE user_id = auth.uid()
    AND date BETWEEN start_date AND end_date
  ORDER BY date ASC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to initialize default config for new user
CREATE OR REPLACE FUNCTION initialize_user_config()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO user_config (user_id)
  VALUES (NEW.id)
  ON CONFLICT (user_id) DO NOTHING;

  INSERT INTO user_preferences (user_id)
  VALUES (NEW.id)
  ON CONFLICT (user_id) DO NOTHING;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to auto-create config when user signs up
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION initialize_user_config();

-- ============================================================================
-- NOTES
-- ============================================================================
--
-- MIGRATION STRATEGY:
-- 1. User signs up/logs in
-- 2. Frontend checks if user_config exists
-- 3. If not, migrate localStorage config to Supabase
-- 4. If exists, merge/sync with local data (newest wins based on updated_at)
--
-- CONFLICT RESOLUTION:
-- - Use updated_at timestamps to determine which data is newer
-- - Client-side: compare localStorage vs Supabase timestamps
-- - Always preserve the most recent change
--
-- OFFLINE SUPPORT:
-- - Continue using localStorage for immediate reads/writes
-- - Queue changes and sync when online
-- - On app load: fetch from Supabase, merge with local, sync conflicts
--
-- ============================================================================
