# Recalibration

> Strip away the noise and see what your body says without it. **Signals, not scores.**

A personal health tracking app for observing how your body responds to experiments like dietary changes, lifestyle modifications, or wellness protocols.

## What It Does

- **Daily Signal Tracking**: Move sliders to capture how you feel across multiple dimensions (mental clarity, energy, gut state, etc.)
- **Smart Tracking**: Only track what matters today - unmoved sliders aren't recorded
- **Experiment Progress**: Visual progress bar with phases and milestones for structured experiments
- **Trend Analysis**: See patterns emerge over time with clear visualizations
- **Cross-Device Sync**: Access your data from phone, tablet, or computer via Supabase
- **Offline-First**: Works without internet, syncs when connected

## Philosophy

Track **signals**, not scores. This isn't about gamification or optimization - it's about honest observation. What does your body say when you strip away the noise?

## Tech Stack

- Single-file HTML app (vanilla JS, no frameworks)
- Supabase for authentication and sync
- PWA-enabled for native app feel
- Dark mode default with Dusk theme option

## Usage

1. Visit [recalibrate.unblocked.health](https://recalibrate.unblocked.health)
2. Create an account or log in
3. **Add to Home Screen** on mobile for app-like experience
4. Start tracking your signals

## Customization

All settings are configurable:
- Custom tracker title and experiment goal
- Define your own phases with colors and messages
- Add milestones for important dates
- Customize signal sliders to track what matters to you
- Configure additional fields for specific tracking needs

## Privacy

- Your data is yours - stored in your personal Supabase account
- No analytics, no tracking, no third parties
- Open source - audit the code yourself

## Development

This is a single-page application built with vanilla JavaScript. The entire app is in `index.html`.

To run locally:
1. Clone the repo
2. Open `index.html` in a browser
3. Set up your own Supabase project and update credentials

## License

MIT

---

Built for people who want to observe themselves clearly.
