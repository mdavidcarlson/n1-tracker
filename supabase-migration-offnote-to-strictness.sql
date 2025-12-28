-- ============================================================================
-- MIGRATION: Rename offnote column to strictness
-- ============================================================================
-- This migration renames the 'offnote' column to 'strictness' in the
-- daily_entries table to reflect the new field purpose and options.
--
-- IMPORTANT: Run this migration on existing Supabase databases that were
-- created with the old schema containing the 'offnote' column.
--
-- Date: 2025-12-28
-- ============================================================================

-- Rename the column from offnote to strictness
ALTER TABLE daily_entries
RENAME COLUMN offnote TO strictness;

-- Update the comment to reflect the new purpose
COMMENT ON COLUMN daily_entries.strictness IS
  'Diet strictness level: N/A, Getting There, Almost there, or BBBE (Beef, Butter, Bacon, Eggs)';

-- ============================================================================
-- NOTES
-- ============================================================================
-- This migration is safe to run on existing databases. PostgreSQL will
-- automatically handle the column rename, and all existing data will be
-- preserved.
--
-- After running this migration, update the user_config.fields default value
-- to include the new strictness field definition if needed (though this is
-- stored per-user and can be updated through the UI).
-- ============================================================================
