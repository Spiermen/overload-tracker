# What you must do (secrets + Apple setup)

The Linux box cannot run Xcode. CI on `macos-14` builds and uploads once these exist.

## 1. App Store Connect (you, in the browser)
1. Create app **DadStrong**, bundle id `com.spiermen.dadstrong`.
2. Create App ID + App Group `group.com.spiermen.dadstrong` in [Apple Developer → Identifiers](https://developer.apple.com/account/resources/identifiers/list).
   - Enable **HealthKit**, **App Groups**, **In-App Purchase**, **Push Notifications** (for local notifs capability is separate; local notifications need the app permission only).
3. Create a second App ID for the widget: `com.spiermen.dadstrong.widget` with the same App Group.
4. Users & Access → **Integrations → App Store Connect API** → Generate a key with **App Manager** (or Admin).
   - Download the `.p8` once.
   - Note **Key ID** and **Issuer ID**.
5. Membership → note your **Team ID**.
6. Create IAP `dadstrong_pro_lifetime` (non-consumable) and submit with the first binary.
7. Create a [RevenueCat](https://app.revenuecat.com) project, add iOS app with this bundle id, create entitlement `pro`, attach the product. Copy the **iOS API key** into `native-bridge.js` (`RC_API_KEY`).

## 2. GitHub repo secrets (Settings → Secrets and variables → Actions)
| Secret | What it is |
| --- | --- |
| `ASC_KEY_ID` | App Store Connect API Key ID |
| `ASC_ISSUER_ID` | Issuer UUID |
| `ASC_KEY_P8` | Full `.p8` file contents (PEM text) **or** base64 of it |
| `ASC_KEY_P8_BASE64` | Set to `1` only if `ASC_KEY_P8` is base64 |
| `ASC_TEAM_ID` | 10-character Team ID |
| `MATCH_GIT_URL` | (Optional) private certs repo for [fastlane match](https://docs.fastlane.tools/actions/match/) |
| `MATCH_PASSWORD` | (Optional) match encryption password |
| `MATCH_GIT_BASIC_AUTHORIZATION` | (Optional) `base64(user:pat)` for match repo |

Repo **variable** (optional): `IOS_AUTO_UPLOAD=1` to upload on every push to `ios`/`main`. Otherwise only **Actions → iOS TestFlight → Run workflow**.

## 3. One-time on a Mac (or Xcode Cloud) — Widget target
Capacitor created the App target. Widget sources live in `ios/App/DadStrongWidget/`.
Add them once in Xcode (or use XcodeGen with `ios/project.yml` if you prefer):
1. File → New → Target → Widget Extension → name `DadStrongWidget`, bundle `com.spiermen.dadstrong.widget`.
2. Replace generated Swift with our `DadStrongWidget.swift`.
3. App Groups on **both** App and Widget: `group.com.spiermen.dadstrong`.
4. App target: enable **HealthKit** + **In-App Purchase** capabilities; entitlements file `App/App.entitlements` is already present.
5. Commit the updated `project.pbxproj`.

Details: `native/WIDGET_SETUP.md`.

## 4. Run the first TestFlight build
1. Push branch `ios` (or merge to `main`).
2. GitHub → Actions → **iOS TestFlight** → **Run workflow**.
3. Install from TestFlight; turn on Health + reminders in Settings; add the widget.
4. Fill App Store listing from `store/APP_STORE_LISTING.md`, upload screenshots, submit for review.

## 5. Codemagic alternative
`codemagic.yaml` is ready. Connect the repo in Codemagic, add the same `ASC_*` env vars, run workflow `dadstrong-ios`.
