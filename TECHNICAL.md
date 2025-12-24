# Recalibrate - Technical Documentation

> Comprehensive technical reference for developers and AI assistants

**Last Updated:** December 24, 2024
**Version:** 1.5.2
**Live URL:** https://recalibrate.unblocked.health

---

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [File Structure](#file-structure)
3. [Database Schema](#database-schema)
4. [Authentication Flow](#authentication-flow)
5. [Data Model](#data-model)
6. [Key Components](#key-components)
7. [State Management](#state-management)
8. [Sync Mechanism](#sync-mechanism)
9. [Offline Functionality](#offline-functionality)
10. [Configuration System](#configuration-system)
11. [Theming](#theming)
12. [Deployment](#deployment)
13. [Common Modifications](#common-modifications)
14. [Troubleshooting](#troubleshooting)

---

## Architecture Overview

**Stack:**
- **Frontend:** Vanilla JavaScript (ES6+), Single HTML file
- **Backend:** Supabase (PostgreSQL + Auth)
- **Hosting:** GitHub Pages (static site)
- **PWA:** Service worker-less PWA with manifest

**Philosophy:**
- Zero build tools, zero dependencies (except Supabase SDK via CDN)
- Offline-first with localStorage caching
- Progressive Web App for native-like experience
- Data ownership: users control their data

**Key Architectural Decisions:**
1. **Single HTML file** - Everything in `index.html` for simplicity
2. **Offline-first** - localStorage as cache, Supabase as sync target
3. **Optimistic UI** - Updates happen immediately, sync in background
4. **Conflict resolution** - Cloud always wins on sync conflicts

---

## File Structure

```
/
├── index.html              # Main app (all HTML, CSS, JS)
├── terms.html              # Terms of Service
├── privacy.html            # Privacy Policy
├── README.md               # User-facing documentation
├── TECHNICAL.md            # This file
├── supabase-schema.sql     # Database schema + RLS policies
└── Favicon/                # PWA icons and manifest
    ├── favicon.ico
    ├── favicon.svg
    ├── favicon-96x96.png
    ├── apple-touch-icon.png
    ├── web-app-manifest-192x192.png
    ├── web-app-manifest-512x512.png
    └── site.webmanifest    # PWA manifest
```

---

## Database Schema

**Supabase Project:** npszsifoxxmiviqpaiog

### Tables

#### `user_config`
User's tracker configuration and settings.

```sql
CREATE TABLE public.user_config (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  title TEXT DEFAULT 'Recalibration',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id)
);
```

#### `daily_entries`
Daily signal tracking data.

```sql
CREATE TABLE public.daily_entries (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  date DATE NOT NULL,
  data JSONB NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, date)
);
```

**JSONB Structure:**
```json
{
  "sliders": {
    "mental_clarity": 2,
    "craving_noise": -1,
    "sleep_waking_state": 3
  },
  "fields": {
    "cramps": "None",
    "palps": "Mild"
  },
  "context": {
    "electrolytes_taken": true,
    "movement_load": "moderate",
    "stress_load": "high"
  },
  "notes": "Optional daily notes"
}
```

#### `user_preferences`
User theme and UI preferences.

```sql
CREATE TABLE public.user_preferences (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  theme TEXT DEFAULT 'dark',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id)
);
```

### Row Level Security (RLS)

All tables have RLS enabled with identical policies:

```sql
-- Users can only view their own data
CREATE POLICY "Users can view their own [table]"
  ON [table] FOR SELECT
  USING (auth.uid() = user_id);

-- Users can only insert their own data
CREATE POLICY "Users can insert their own [table]"
  ON [table] FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Users can only update their own data
CREATE POLICY "Users can update their own [table]"
  ON [table] FOR UPDATE
  USING (auth.uid() = user_id);

-- Users can only delete their own data
CREATE POLICY "Users can delete their own [table]"
  ON [table] FOR DELETE
  USING (auth.uid() = user_id);
```

### Triggers

**Auto-initialize user data on signup:**

```sql
CREATE OR REPLACE FUNCTION public.initialize_user_config()
RETURNS TRIGGER
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
BEGIN
  INSERT INTO public.user_config (user_id)
  VALUES (NEW.id)
  ON CONFLICT (user_id) DO NOTHING;

  INSERT INTO public.user_preferences (user_id)
  VALUES (NEW.id)
  ON CONFLICT (user_id) DO NOTHING;

  RETURN NEW;
EXCEPTION WHEN OTHERS THEN
  RAISE WARNING 'Failed to initialize user config: %', SQLERRM;
  RETURN NEW;
END;
$$;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.initialize_user_config();
```

---

## Authentication Flow

**Provider:** Supabase Auth (email/password)

**Flow:**
1. User visits site → `initializeApp()` checks for session
2. If no session → show `authScreen`
3. User signs up/logs in → `handleSignup()` or `handleLogin()`
4. Email verification required (configured in Supabase dashboard)
5. On successful auth → `onAuthStateChange(true)` fires
6. Load user data → `loadFromSupabase()` → show `mainApp`

**Session Management:**
- Supabase handles tokens automatically
- Session stored in localStorage by Supabase SDK
- Auto-refresh on token expiry
- Logout → `handleLogout()` → clears session

**Key Functions:**

```javascript
// Initialize app and check auth state
async function initializeApp()

// Handle signup
async function handleSignup()

// Handle login
async function handleLogin()

// Handle logout
async function handleLogout()

// Auth state changed (login/logout)
async function onAuthStateChange(isAuthenticated)
```

---

## Data Model

### Configuration Object

**Stored in:** `user_config` table (Supabase) + `localStorage` (cache)

```javascript
const DEFAULT_CONFIG = {
  version: 3,
  title: "Recalibration",
  experiment: {
    enabled: true,
    startDate: "2026-01-06",
    endDate: "2026-04-05",
    goal: "90-Day Carnivore Reset",
    chapters: [
      {
        name: "Orientation",
        endDay: 7,
        color: "#2DD4BF",
        message: "Getting oriented to the signals"
      }
    ],
    milestones: [
      {
        date: "2026-01-06",
        label: "HTMA Test #1"
      }
    ]
  },
  sliders: [
    {
      id: "mental_clarity",
      label: "Mental Clarity",
      left: "Brain fog",
      right: "Clear-headed",
      min: -3,
      max: 3
    }
  ],
  fields: [
    {
      id: "cramps",
      label: "Muscle Cramps",
      type: "select",
      options: ["—", "None", "Mild", "Wakes-me-up"]
    }
  ],
  context: {
    electrolytes_taken: false,
    movement_load: "none",
    stress_load: "none"
  }
};
```

### Daily Entry Object

**Stored in:** `daily_entries` table (Supabase) + `localStorage` (cache)

```javascript
const entry = {
  id: "uuid",
  user_id: "uuid",
  date: "2025-12-23",
  data: {
    sliders: { mental_clarity: 2 },
    fields: { cramps: "None" },
    context: { electrolytes_taken: true },
    notes: "Felt great today"
  },
  created_at: "2025-12-23T10:00:00Z",
  updated_at: "2025-12-23T10:00:00Z"
};
```

---

## Key Components

### 1. Entry Form (`renderEntryForm()`)

**Purpose:** Render daily tracking interface

**Key Features:**
- Dynamic slider generation from config
- Conditional field rendering (select/text/number)
- Experiment day calculation
- Saves to localStorage immediately
- Syncs to Supabase in background

### 2. Analysis Tab (`renderTrends()`)

**Purpose:** Visualize signal trends over time

**Chart Types:**
- Individual line charts per slider
- Overlay mode (all signals on one chart)
- Rolling averages (7/14/30 day)
- Date range filtering

**Implementation:**
- Canvas-based rendering (no chart library)
- Responsive to container size
- Shows N/A for unmoved sliders

### 3. Experiment Tracker

**Purpose:** Visual progress bar with phases and milestones

**Features:**
- Color-coded phases based on day number
- Milestone markers on timeline
- Days remaining countdown
- Current phase message display

### 4. Settings Modal

**Tabs:**
- **General:** Tracker title
- **Experiment:** Progress tracker config, phases, milestones
- **Tracking Setup:** Slider and field customization
- **Data:** Import/export, reset
- **Account:** Email, sync status, logout

---

## State Management

**Strategy:** Dual-storage with eventual consistency

### localStorage (Primary Cache)

```javascript
// Config
localStorage.setItem('trackerConfig', JSON.stringify(config));

// Entries (all dates)
localStorage.setItem('dailyEntries', JSON.stringify(entries));

// Theme preference
localStorage.setItem('theme', 'dark');

// App version (for cache busting)
localStorage.setItem('appVersion', '1.5.2');
```

### Supabase (Cloud Sync)

**Config:**
- Table: `user_config`
- Syncs on: save settings, login

**Entries:**
- Table: `daily_entries`
- Syncs on: save entry, manual sync, login

**Conflict Resolution:**
- Cloud always wins on load
- Local cache immediately on save
- Background sync reconciles

---

## Sync Mechanism

### Sync Flow

```
User Action
    ↓
Update localStorage (immediate)
    ↓
Update UI (immediate)
    ↓
Sync to Supabase (background)
    ↓
Update sync indicator
```

### Sync Functions

```javascript
// Sync all entries to cloud
async function syncAllEntries()

// Sync single entry to cloud
async function syncEntry(entry)

// Load all data from cloud (on login)
async function loadFromSupabase()

// Manual sync trigger
async function forceSyncAll()
```

### Sync Indicators

- **Green dot:** Connected & synced
- **Yellow dot:** Syncing in progress
- **Red dot:** Offline or error
- **Gray dot:** Not connected

**Location:** Header (always visible) + Account tab

---

## Offline Functionality

**Strategy:** Works 100% offline, syncs when online

### Offline Capabilities
- ✅ Track daily signals
- ✅ View all historical data
- ✅ Analyze trends
- ✅ Modify settings
- ✅ Export data

### Online Detection

```javascript
let isOnline = navigator.onLine;

window.addEventListener('online', () => {
  isOnline = true;
  syncAllEntries();
});

window.addEventListener('offline', () => {
  isOnline = false;
  updateSyncStatus('offline');
});
```

### Pending Sync Queue

Entries modified offline are tracked and synced when connection returns.

```javascript
let pendingSync = []; // Tracks entries needing sync

// On save
if (isOnline) {
  await syncEntry(entry);
} else {
  pendingSync.push(entry);
}

// On reconnect
window.addEventListener('online', async () => {
  for (const entry of pendingSync) {
    await syncEntry(entry);
  }
  pendingSync = [];
});
```

---

## Configuration System

### Config Versioning

**Purpose:** Handle breaking changes to config structure

```javascript
const CONFIG_VERSION = 3;

function loadConfig() {
  const saved = localStorage.getItem('trackerConfig');
  const config = saved ? JSON.parse(saved) : DEFAULT_CONFIG;

  // Version migration logic
  if (!config.version || config.version < CONFIG_VERSION) {
    return migrateConfig(config);
  }

  return config;
}
```

### Customization Points

Users can customize:
1. **Tracker title** - App name
2. **Experiment config** - Goal, dates, phases, milestones
3. **Sliders** - Custom metrics with anchors
4. **Fields** - Additional tracking (select/text/number)
5. **Context** - Binary toggles and dropdowns

### Import/Export

**Export:**
- Format: JSON
- Contains: Full config (sliders, fields, experiment)
- Use: Backup, share templates

**Import:**
- Upload JSON file
- Validates structure
- Merges with existing config
- Does NOT overwrite entries

---

## Theming

### Theme System

**Three themes:**
1. **Light Mode** - Clean canvas (#F8FAFC background)
2. **Dark Mode** - Cosmic ocean (#0F172A background) **[default]**
3. **Dusk Mode** - Sunset horizon (#1C1E2E background)

### CSS Variables

All colors use CSS custom properties:

```css
:root {
  /* Light Mode */
  --bg-primary: #F8FAFC;
  --bg-secondary: #FFFFFF;
  --text-primary: #1E293B;
  --accent-primary: #2DD4BF;
}

body.dark-mode {
  /* Dark Mode */
  --bg-primary: #0F172A;
  --bg-secondary: #1E293B;
  --text-primary: #E2E8F0;
  --accent-primary: #2DD4BF;
}

body.dusk-mode {
  /* Dusk Mode */
  --bg-primary: #1C1E2E;
  --bg-secondary: #2B2638;
  --text-primary: #EDD5D1;
  --accent-primary: #E8A87C;
}
```

### Theme Toggle

Cycles: Light → Dark → Dusk → Light

```javascript
function toggleDarkMode() {
  const currentTheme = localStorage.getItem('theme') || 'dark';

  // Cycle logic
  let nextTheme =
    currentTheme === 'light' ? 'dark' :
    currentTheme === 'dark' ? 'dusk' : 'light';

  // Apply theme
  document.body.classList.remove('dark-mode', 'dusk-mode');
  if (nextTheme === 'dark') {
    document.body.classList.add('dark-mode');
  } else if (nextTheme === 'dusk') {
    document.body.classList.add('dusk-mode');
  }

  localStorage.setItem('theme', nextTheme);
}
```

### Default Theme

**Dark mode** is default (set on initial load):

```javascript
const savedTheme = localStorage.getItem('theme') || 'dark';
```

---

## Deployment

### GitHub Pages Setup

**Repository:** mdavidcarlson/recalibrate
**Branch:** `claude/daily-tracker-app-txMxk`
**Custom Domain:** recalibrate.unblocked.health

**DNS Configuration (GoDaddy):**
```
Type: CNAME
Name: recalibrate
Value: mdavidcarlson.github.io
```

**GitHub Pages Settings:**
1. Settings → Pages
2. Source: Deploy from branch
3. Branch: `claude/daily-tracker-app-txMxk` / `root`
4. Custom domain: `recalibrate.unblocked.health`
5. Enforce HTTPS: ✅

### PWA Installation

**Manifest:** `/Favicon/site.webmanifest`

```json
{
  "name": "Recalibrate",
  "short_name": "Recalibrate",
  "display": "standalone",
  "theme_color": "#0F172A",
  "background_color": "#0F172A",
  "icons": [...]
}
```

**iOS:** Safari → Share → Add to Home Screen
**Android:** Chrome → Menu → Install app

### Cache Busting

**Version Check System:**

```javascript
const APP_VERSION = '1.5.2';

(function checkVersion() {
  const storedVersion = localStorage.getItem('appVersion');
  if (storedVersion !== APP_VERSION) {
    // Clear cache (except auth tokens)
    localStorage.clear();
    // Restore auth
    // Force reload
    location.reload(true);
  }
})();
```

**When to bump version:**
- Breaking config structure changes
- Major UI refactors
- Schema migrations
- Cache corruption fixes

---

## Common Modifications

### Adding a New Slider

1. **Update DEFAULT_CONFIG:**

```javascript
sliders: [
  {
    id: "new_metric",
    label: "New Metric",
    left: "Low anchor",
    right: "High anchor",
    min: -3,
    max: 3
  }
]
```

2. **No code changes needed** - dynamically rendered
3. Save settings to update user config

### Adding a New Field

```javascript
fields: [
  {
    id: "new_field",
    label: "New Field",
    type: "select", // or "text" or "number"
    options: ["Option 1", "Option 2"] // only for select
  }
]
```

### Changing Experiment Default

```javascript
experiment: {
  enabled: true,
  startDate: "2026-01-06", // Update this
  endDate: "2026-04-05",   // Update this
  goal: "Your Goal Here",  // Update this
  chapters: [...],
  milestones: [...]
}
```

### Adding a New Theme

1. **Add CSS variables:**

```css
body.new-theme {
  --bg-primary: #hexcolor;
  --bg-secondary: #hexcolor;
  /* ... all other variables */
}
```

2. **Update toggle function:**

```javascript
function toggleDarkMode() {
  // Add 'new-theme' to cycle
}
```

3. **Update manifest theme_color** (optional)

---

## Troubleshooting

### Common Issues

#### Settings Button Doesn't Work

**Cause:** JavaScript error on `renderSettingsModal()`
**Check:** Browser console for errors
**Fix:** Ensure all element IDs referenced exist in HTML

#### Data Not Syncing

**Cause:** Authentication issue or RLS policy problem
**Check:**
1. User logged in? (`currentUser` is set)
2. Network tab shows 200 responses?
3. RLS policies exist and reference `auth.uid()`

**Fix:**
```sql
-- Verify RLS enabled
SELECT tablename, rowsecurity
FROM pg_tables
WHERE schemaname = 'public';

-- Should show TRUE for user_config, daily_entries, user_preferences
```

#### Blank Page After Update

**Cause:** Cached old version with breaking changes
**Fix:** Bump `APP_VERSION` → force cache clear on next load

#### "Relation does not exist" Error on Signup

**Cause:** Database trigger can't find tables
**Fix:** Add `SET search_path = public` to trigger function

```sql
CREATE OR REPLACE FUNCTION public.initialize_user_config()
RETURNS TRIGGER
SECURITY DEFINER
SET search_path = public  -- Add this
LANGUAGE plpgsql
```

#### Chart Not Rendering

**Cause:** Not enough data points
**Check:** Need at least 3 entries with moved sliders
**Debug:** Console shows "Need at least 3 days of data"

---

## Security Considerations

### Authentication
- ✅ Email verification required (set in Supabase dashboard)
- ✅ Passwords hashed by Supabase Auth
- ✅ Session tokens auto-managed
- ⚠️ No 2FA (Supabase feature, not enabled)

### Data Access
- ✅ Row Level Security enforces user isolation
- ✅ `auth.uid()` ensures users only access own data
- ✅ HTTPS enforced on custom domain
- ✅ No analytics or tracking scripts

### API Keys
- ⚠️ Supabase `anon` key is public (by design)
- ✅ RLS policies protect data even with public key
- ✅ Service role key NOT exposed (stays server-side)

### Vulnerabilities to Monitor
- **SQL Injection:** Mitigated by Supabase parameterized queries
- **XSS:** Mitigated by using `textContent` not `innerHTML` for user data
- **CSRF:** Not applicable (no session cookies)
- **Rate Limiting:** Supabase handles this

---

## Performance Optimization

### Current Performance

- **First Load:** ~500ms (HTML + Supabase SDK)
- **Time to Interactive:** ~800ms
- **Entry Save:** Instant (localStorage) + background sync
- **Trend Rendering:** ~100ms for 90 days of data

### Optimizations Applied

1. **Lazy Load Supabase SDK** - Only when authenticated
2. **Debounced Sync** - Avoid rapid-fire API calls
3. **localStorage Cache** - Instant reads, no API calls
4. **Canvas Charts** - Fast, no SVG DOM manipulation
5. **Single HTML File** - No round trips for assets

### If Performance Degrades

**Problem:** Chart rendering slow
**Solution:** Limit data points, add pagination

**Problem:** Sync taking too long
**Solution:** Batch upserts, use Supabase bulk insert

**Problem:** localStorage full
**Solution:** Limit cached entries to last 365 days

---

## API Reference

### Supabase Client

```javascript
const { createClient } = supabase;
const sb = createClient(SUPABASE_URL, SUPABASE_KEY);
```

### Key API Calls

**Auth:**
```javascript
// Sign up
await sb.auth.signUp({ email, password });

// Sign in
await sb.auth.signInWithPassword({ email, password });

// Sign out
await sb.auth.signOut();

// Get session
const { data: { session } } = await sb.auth.getSession();
```

**Database:**
```javascript
// Insert/Update (upsert)
await sb.from('daily_entries')
  .upsert({ user_id, date, data })
  .eq('user_id', user_id);

// Select
const { data } = await sb.from('daily_entries')
  .select('*')
  .eq('user_id', user_id);

// Delete
await sb.from('daily_entries')
  .delete()
  .eq('id', entry_id);
```

---

## Version History

**1.5.2** (Current)
- Fixed app icon name to "Recalibrate"

**1.5.1**
- Added email verification requirement
- Added Terms of Service and Privacy Policy pages

**1.5.0**
- Added PWA support (installable app)
- Created README.md

**1.4.3**
- Moved "Signals, not scores" tagline to separate line

**1.4.2**
- Fixed settings button after tab reorganization

**1.4.1**
- Updated title to "Recalibration"
- Added new tagline with "Signals, not scores"

**1.4.0**
- Major tab reorganization (General vs Experiment)
- Restored "phases" terminology throughout

**1.3.x**
- Added three-theme system (Light/Dark/Dusk)
- Added cache-busting version check system

**1.0.0**
- Initial release with Supabase sync

---

## Development Workflow

### Local Development

1. Clone repo
2. Open `index.html` in browser
3. Sign up with test email
4. Make changes to `index.html`
5. Refresh browser to test

**No build step required!**

### Testing

**Manual Testing Checklist:**
- [ ] Signup flow with email verification
- [ ] Login/logout
- [ ] Save entry (check localStorage)
- [ ] Sync entry (check Supabase)
- [ ] Offline mode (disable network, save entry)
- [ ] Settings save/load
- [ ] Import/export config
- [ ] Theme toggle
- [ ] Chart rendering

### Deployment

```bash
git add .
git commit -m "Description of changes"
git push origin claude/daily-tracker-app-txMxk
```

GitHub Pages auto-deploys in ~1-2 minutes.

### Version Bumping

When making breaking changes:

```javascript
// In index.html
const APP_VERSION = '1.5.3'; // Increment this
```

This forces cache clear for all users on next visit.

---

## Contact & Support

**Repository:** https://github.com/mdavidcarlson/recalibrate
**Live App:** https://recalibrate.unblocked.health
**Issues:** Use GitHub Issues for bugs/features

---

## License

MIT License - See repository for details

---

**This documentation is intended for:**
- Developers modifying the codebase
- AI assistants providing technical support
- Future maintainers understanding architecture

**For user-facing documentation, see:** [README.md](README.md)
