# Getting Started with Your Daily Tracker - Complete Beginner's Guide

**Total time needed: 5 minutes**

---

## Step 1: Open and Test the Enhanced Tracker (2 minutes)

### 1a. Find the File

The file is here: `/home/user/HIC/n1-tracker-enhanced.html`

### 1b. Open in Your Browser

**Option A - Double-click (easiest):**
1. Open your file explorer
2. Navigate to: `/home/user/HIC/`
3. Find the file: `n1-tracker-enhanced.html`
4. Double-click it
5. It should open in your default browser (Chrome, Firefox, Safari, etc.)

**Option B - Drag and drop:**
1. Open your browser (Chrome, Firefox, etc.)
2. Drag the `n1-tracker-enhanced.html` file into the browser window
3. Drop it

**Option C - From browser:**
1. Open your browser
2. Press `Ctrl+O` (Windows/Linux) or `Cmd+O` (Mac)
3. Navigate to `/home/user/HIC/n1-tracker-enhanced.html`
4. Click "Open"

### 1c. Take the Tour (Follow Along)

Once the page opens, you'll see the tracker. Let's try everything:

#### **Test 1: Basic Daily Entry (30 seconds)**

1. **Date field** - Should show today's date already. If not, click and select today.

2. **Day # field** - Type `1` (since this is day 1 of your tracking)

3. **Scroll down to the sliders** - You'll see 6 sliders:
   - Mental Clarity
   - Food Focus
   - Sleep (Waking State)
   - Gut State
   - Energy Stability
   - Joint Comfort

4. **Move any slider** - Click and drag one. Watch the number change from 0 to something else.
   - Left side = negative symptoms
   - Right side = positive symptoms
   - Middle (0) = neutral

5. **Fill in a dropdown** - Under "Additional Fields", click "Cramps" and select "None"

6. **Add a note** - In the "Notes" box at the bottom, type: "Testing the tracker!"

7. **Click the blue "Save Day" button**

8. **Look for confirmation** - You should see a green message: "Saved entry for [today's date]"

9. **Scroll to bottom** - Look at the table. You should see your entry listed!

**✅ If you see your entry in the table, you've successfully tracked your first day!**

---

#### **Test 2: Customize Your Tracker (1 minute)**

Now let's make it YOUR tracker by changing what you track:

1. **Find the "⚙️ Customize" button** - It's next to "Track Metrics" header

2. **Click it** - A settings panel appears!

3. **Change the title:**
   - At the top, find "Tracker Title"
   - Change it to: "My 90-Day Reset Tracker"

4. **Edit a slider:**
   - Find "Slider 1" (Mental Clarity)
   - Change "Mental Clarity" to "Brain Power"
   - Change "Brain fog" to "Foggy"
   - Change "Clear-headed" to "Super sharp"

5. **Add a new slider:**
   - Click the "+ Add Slider" button
   - In the new box, type:
     - Label: "Mood"
     - Left label: "Grumpy"
     - Right label: "Happy"

6. **Click "Save Settings"**

7. **Watch the magic** - The tracker updates! You should now see:
   - New title at the top
   - "Brain Power" instead of "Mental Clarity"
   - A new "Mood" slider at the bottom

**✅ If you see your changes, you just customized the tracker without touching any code!**

---

#### **Test 3: Export Your Data (30 seconds)**

This is how you back up your tracking data:

1. **Find the "📥 Export CSV" button** - It's in the middle section

2. **Click it**

3. **A file downloads** - Named something like `n1_daily_log_2025-12-18.csv`

4. **Find the downloaded file** - Check your Downloads folder

5. **Double-click it** - It should open in Excel or Google Sheets

6. **Look at your data** - You'll see your entry in spreadsheet format!

**✅ If you see a spreadsheet with your data, you know how to back up your tracking!**

---

#### **Test 4: Export Settings Template (30 seconds)**

This is how you'd share your customized tracker with someone else:

1. **Find the "📋 Export Settings Template" button**

2. **Click it**

3. **A file downloads** - Named something like `tracker_settings_2025-12-18.json`

4. **That's it!** - This file contains your slider/field setup, but NO personal data

**Why this matters:** You could send this file to a friend. They click "📋 Import Settings Template", select your file, and boom - they have your exact tracking setup but with zero data.

---

## Step 2: See What Makes This "Enhanced" (1 minute)

You don't have the "original" version I evaluated, but here's what you'd have had to do WITHOUT the enhancements:

### To Add "Mood" Tracking in Original Version:

```html
<!-- You'd have to find this in the HTML code: -->
<div class="slider-group">
  <div class="slider-header">
    <span>Joint Comfort</span>  <!-- Find the last slider -->
    ...
  </div>
  ...
</div>

<!-- Then copy/paste this entire block: -->
<div class="slider-group">
  <div class="slider-header">
    <span>Mood</span>  <!-- Type your new slider name -->
    <span class="value-display" id="val-mood">0</span>  <!-- Create unique ID -->
  </div>
  <div class="slider-label">
    <span>Grumpy</span>  <!-- Left label -->
    <span>Happy</span>   <!-- Right label -->
  </div>
  <input type="range" id="mood" min="-5" max="5" value="0" step="1">
</div>

<!-- Then scroll down and add JavaScript: -->
<script>
  bindSlider('mood', 'val-mood');  // Add this line
</script>

<!-- Then update the save function: -->
const entry = {
  // ... existing fields ...
  mood: getValue('mood'),  // Add this line
};

<!-- Then update the table headers... -->
<!-- And the CSV export headers... -->
<!-- And the field array... -->
```

**That's about 50 lines of code across 5 different locations.**

### What You Just Did in Enhanced Version:

1. Click ⚙️
2. Click + Add Slider
3. Type "Mood", "Grumpy", "Happy"
4. Click Save

**That's it. 4 clicks.**

**✅ See why the enhanced version matters? You're not a programmer - you shouldn't have to be!**

---

## Step 3: Create a Pull Request (Optional - 1 minute)

**What's a Pull Request (PR)?**
A PR is like saying "Hey, I made some changes, can we make them official?"

Since this is already committed to your branch, you have two options:

### Option A: Just Keep Using Your Branch (Simplest)
- You already have the files
- They're saved in git
- You can just start using the tracker
- **Do this if:** You're the only one using this, or you just want to get started

### Option B: Create a Pull Request (More Formal)
- Merges your changes into the main branch
- Creates a record of what changed
- Good for team projects
- **Do this if:** You want to integrate this into a larger project

**To create a PR:**

1. **Go to your repository on GitHub**
   - The URL is probably something like: `https://github.com/mdavidcarlson/HIC`

2. **You should see a yellow banner** that says:
   - "claude/daily-tracker-app-txMxk had recent pushes"
   - With a button: "Compare & pull request"

3. **Click "Compare & pull request"**

4. **Fill in the form:**
   - Title: "Add enhanced daily tracker with customizable UI"
   - Description: Copy this:
   ```
   Added a customizable daily tracker for 30-90 day diet logs.

   Features:
   - Visual settings panel (no coding required)
   - Template import/export for sharing
   - CSV import/export for backups
   - Mobile-responsive design
   - Automatic backup reminders

   Files:
   - n1-tracker-enhanced.html - The tracker app
   - UX_EVALUATION.md - Design analysis
   - GETTING_STARTED.md - User guide
   ```

5. **Click "Create pull request"**

**✅ That's it! The PR is created.**

---

## Step 4: Share Feedback with Me (Anytime)

If you want changes, just tell me in plain English. Examples:

### Good Feedback Examples:

**"The sliders are confusing. Can we use buttons instead?"**
- Clear problem + clear solution

**"I want to track my weight every day. How do I add that?"**
- Clear need

**"The green success message disappears too fast - I can't read it"**
- Specific issue

**"Can you make the date field bigger? I keep missing it on my phone"**
- Specific + context

### I Can Help With:

- ✅ Changing how anything looks (colors, sizes, layout)
- ✅ Adding new features (graphs, streaks, reminders)
- ✅ Simplifying anything that's confusing
- ✅ Making it work better on your phone
- ✅ Fixing bugs or problems
- ✅ Explaining how anything works

### Just Say Things Like:

- "Can you add ____?"
- "I don't understand ____"
- "Can we change ____ to ____?"
- "This is annoying: ____"
- "I wish it would ____"

**I'll handle the technical stuff. You just tell me what you want!**

---

## Quick Reference Card

**Daily Workflow:**
1. Open `n1-tracker-enhanced.html` in browser
2. Adjust sliders
3. Fill in any dropdowns/fields
4. Add notes if needed
5. Click "Save Day"
6. Close browser

**Weekly Backup:**
1. Click "📥 Export CSV"
2. Save file somewhere safe

**Customize Tracker:**
1. Click "⚙️ Customize"
2. Make changes
3. Click "Save Settings"

**Share With Friend:**
1. Click "📋 Export Settings Template"
2. Send them the .json file
3. They click "📋 Import Settings Template"

---

## Troubleshooting

**Problem: I don't see my saved entries**
- Solution: Make sure you clicked "Save Day" (look for green confirmation message)
- Check: Are you using the same browser? Data is stored per-browser.

**Problem: My data disappeared**
- Likely cause: Browser cache was cleared
- Solution: Import your last CSV export
- Prevention: Export CSV weekly!

**Problem: Sliders won't move on my phone**
- Solution: Make sure you're tapping and dragging, not just tapping
- Try: Use two fingers to scroll the page, one finger to move sliders

**Problem: I edited the settings but nothing changed**
- Solution: Did you click "Save Settings"? (not just close the modal)
- Check: Refresh the page and see if changes stick

**Problem: CSV export opens as gibberish**
- Solution: Right-click → "Open with" → Choose Excel or Google Sheets
- Or: Import the file into Google Sheets manually

**Problem: I want to start over completely**
- Solution: Click "Clear All Data" (red button)
- Warning: This deletes everything! Export CSV first if you want to keep anything.

---

## What to Do RIGHT NOW

1. **Open the tracker** (double-click `n1-tracker-enhanced.html`)
2. **Add one test entry** (just move sliders randomly, click Save)
3. **Customize something** (change one slider label, just to try it)
4. **Export a CSV** (see what it looks like)

**Then start using it for real tomorrow morning!**

Set up your tracking criteria tonight, then begin Day 1 tomorrow.

---

## Need Help?

Just ask me:
- "How do I ____?"
- "This isn't working: ____"
- "Can you explain ____?"

I'll walk you through it step by step.

**You've got this! The tracker is designed to be simple - if something feels hard, that's a design problem I can fix.**
