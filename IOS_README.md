# DadStrong iOS (Capacitor)

Wraps the DadStrong PWA (`index.html` → synced to `www/`) as a native iPhone app.

| | |
| --- | --- |
| Bundle ID | `com.spiermen.dadstrong` |
| Widget | `com.spiermen.dadstrong.widget` |
| App Group | `group.com.spiermen.dadstrong` |
| Web (unchanged) | https://spiermen.github.io/overload-tracker/ |

## Native features (guideline 4.2)
- **HealthKit** — `plugins/dadstrong-bridge` saves finished workouts
- **Local notifications** — workout reminders (`@capacitor/local-notifications`)
- **WidgetKit** — streak + last workout (`ios/App/DadStrongWidget`)
- **Pro unlock** — RevenueCat scaffold (`@revenuecat/purchases-capacitor`); gates unlimited friends

## Commands (Linux OK except archive)
```bash
npm ci
npm run sync:www      # copy PWA → www/
npx cap sync ios      # copy into Xcode project
npm run verify        # lint workflow + sanity checks
```

Build/upload: GitHub Actions workflow `iOS TestFlight` (macos-14) or Codemagic — see `store/SECRETS_AND_CHECKLIST.md`.

## Keep the web app working
GitHub Pages still serves root `index.html`. `native-bridge.js` no-ops when Capacitor is absent. Do not delete root PWA files when syncing.
