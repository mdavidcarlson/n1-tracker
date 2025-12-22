# Supabase Setup Instructions for Recalibrate

This guide will walk you through setting up Supabase for cross-device sync.

## Part 1: Create Your Supabase Project (5 minutes)

### Step 1: Sign Up for Supabase
1. Go to https://supabase.com
2. Click "Start your project"
3. Sign up with GitHub (recommended) or email
4. Verify your email if needed

### Step 2: Create a New Project
1. Click "New Project"
2. Choose your organization (or create one)
3. Fill in project details:
   - **Name**: `recalibrate` (or whatever you prefer)
   - **Database Password**: Generate a strong password (save this!)
   - **Region**: Choose closest to you (e.g., "US West" for California)
   - **Pricing Plan**: Free (perfect for personal use)
4. Click "Create new project"
5. Wait 2-3 minutes for setup to complete

### Step 3: Run the Database Schema
1. In your Supabase dashboard, click **SQL Editor** (left sidebar)
2. Click "New Query"
3. Open the file `supabase-schema.sql` in this repository
4. Copy the entire contents
5. Paste into the Supabase SQL editor
6. Click "Run" (or press Cmd/Ctrl + Enter)
7. You should see: "Success. No rows returned"

✅ **Your database is now set up!**

### Step 4: Get Your API Credentials
1. In Supabase dashboard, click **Settings** (gear icon, bottom left)
2. Click **API** in the sidebar
3. You'll see two important values:
   - **Project URL** (looks like: `https://xxxxx.supabase.co`)
   - **anon/public key** (looks like: `eyJhbGc...`)
4. Keep this tab open - we'll need these values in the next step

## Part 2: Configure Authentication

### Step 5: Enable Email Authentication
1. In Supabase dashboard, click **Authentication** (left sidebar)
2. Click **Providers**
3. Make sure **Email** is enabled (it should be by default)
4. Scroll down to "Email Auth" settings:
   - ✅ Enable email confirmations (recommended)
   - ✅ Enable email change confirmations
   - Set "Site URL" to where you'll host the app (e.g., your GitHub Pages URL)
5. Click "Save"

### Optional: Enable Google Sign-In (Recommended)
1. Still in **Authentication > Providers**
2. Find **Google** and click the toggle
3. You'll need to:
   - Go to Google Cloud Console (https://console.cloud.google.com)
   - Create a project
   - Enable Google+ API
   - Create OAuth credentials
   - Copy Client ID and Client Secret to Supabase
4. This is optional but makes login easier on mobile

## Part 3: Security Configuration

### Step 6: Configure Email Templates (Optional but Recommended)
1. In **Authentication > Email Templates**
2. Customize the confirmation email to match "Recalibrate" branding
3. You can use the cosmic ocean color scheme: `#2DD4BF`

### Step 7: Set Up URL Configuration
1. In **Authentication > URL Configuration**
2. Set "Site URL" to your app's URL:
   - If using GitHub Pages: `https://yourusername.github.io/recalibrate/`
   - If local: `http://localhost:8000`
3. Add redirect URLs (same as site URL)
4. Click "Save"

## Part 4: Provide Credentials to the App

### Step 8: Share Your API Keys
Once you've completed the steps above, I'll need two values to integrate Supabase:

1. **Supabase URL**: `https://xxxxx.supabase.co`
2. **Supabase Anon Key**: `eyJhbGc...` (the long string)

**IMPORTANT**:
- The "anon key" is safe to use in the frontend (it's designed for browser use)
- Never share your "service_role" key (that one is secret!)
- These keys will be added to `index.html` in a configuration section

---

## What Happens Next

After you provide your credentials, I will:

1. ✅ Add Supabase client library to `index.html`
2. ✅ Implement login/signup UI
3. ✅ Migrate your existing localStorage data to Supabase (on first login)
4. ✅ Update all data operations to sync with Supabase
5. ✅ Add offline support (so the app still works without internet)
6. ✅ Test cross-device sync

---

## Expected Results

After setup is complete:
- 🔐 You'll have a login screen when you first open the app
- 💾 All your data will be stored in Supabase (encrypted at rest)
- 🔄 Changes on one device will sync to all other devices
- 📱 Works on phone, tablet, and desktop
- 🌐 Works offline (syncs when connection returns)
- 🔒 Your data is private and secure (Row Level Security)

---

## Troubleshooting

### "Row Level Security" errors
- Run the schema SQL again - the RLS policies might not have applied

### Can't sign up
- Check that email provider is enabled in Authentication > Providers
- Check that Site URL is set correctly

### Data not syncing
- Check browser console for errors (F12)
- Verify API keys are correct
- Check network tab to see if requests are failing

---

## Free Tier Limits

Supabase Free tier includes:
- ✅ 500 MB database storage (plenty for years of daily tracking)
- ✅ 5 GB bandwidth per month
- ✅ 50,000 monthly active users (you'll only have 1!)
- ✅ Unlimited API requests
- ✅ 2 GB file storage (not needed for this app)

You won't hit these limits with personal use. 👍

---

## Ready?

Once you've completed Steps 1-7 above, let me know and provide:
1. Your Supabase URL
2. Your anon key

Then I'll integrate everything! 🚀
