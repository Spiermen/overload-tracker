# DadStrong — App Store listing draft

## Identity
| Field | Value |
| --- | --- |
| **Name** | DadStrong |
| **Subtitle** (30 chars) | Lifts for busy fathers |
| **Bundle ID** | `com.spiermen.dadstrong` |
| **SKU** | `dadstrong001` |
| **Primary category** | Health & Fitness |
| **Secondary** | Lifestyle |
| **Content rating** | 4+ |
| **Price** | Free (Pro unlock IAP) |

## Description (ready to paste)

DadStrong is the progressive-overload workout log built for busy fathers.

Log sets in seconds. Last session’s numbers fill in automatically — you just beat them. Track weight, reps, estimated 1RM, volume, and timed work (runs, planks, lunges). Earn dad badges for showing up. Compare lifts with friends via a private link — no accounts.

**Made for real life**
• Works offline — your gym’s basement wifi won’t matter  
• Resume or edit any workout if you finish early by mistake  
• Countdown + stopwatch usable in any session  
• English & Español  

**iPhone extras**
• Save finished workouts to Apple Health  
• Local workout reminders  
• Home Screen widget: week streak + last session  

Your data stays on your phone. Export a JSON backup anytime. No account required.

## Promotional text (170 chars)
Show up. Log the work. Beat last time. DadStrong helps busy dads build strength one session at a time — with Health, reminders, and a streak widget.

## Keywords (100 chars, comma-separated, no spaces after commas ideally)
workout,gym,father,dad,strength,lifting,progressive overload,PR,fitness,log,tracker,health

## What’s New (1.0)
First release: progressive overload logger, dad badges, friend compare, Apple Health, reminders, Home Screen widget, optional DadStrong Pro.

## Privacy (App Privacy “nutrition labels”)
Answer **No** to tracking.  
Data collected: **None** linked to identity.  
Optional HealthKit: workouts you choose to save are written to Apple Health (on-device).  
Data types used only on device: Workout History (HealthKit write).  
Purchases: handled by Apple / RevenueCat for Pro unlock; no workout data leaves the device for ads.

Privacy policy URL (host a short page): e.g. `https://spiermen.github.io/overload-tracker/privacy.html`  
Support URL: same repo Discussions or your email.

## IAP product (scaffold)
| Product ID | Type | Suggested price |
| --- | --- | --- |
| `dadstrong_pro_lifetime` | Non-consumable | $4.99–$9.99 |
| Entitlement (RevenueCat) | `pro` | — |

## Screenshots required (App Store Connect)
Capture on **iPhone 6.7"** (iPhone 15/16 Pro Max, 1290×2796) and **6.1"** (1179×2556) at minimum.

Suggested 6 frames:
1. Home — Ready to lift + badges  
2. Active workout with PR highlight  
3. Progress chart for a lift  
4. Friend compare  
5. Apple Health / reminders settings (native)  
6. Widget on Home Screen  

Optional: 6.5" legacy, iPad 12.9" if you check iPad.

## Review notes (for Apple)
“DadStrong wraps our workout PWA in Capacitor with native HealthKit workout writes, local notification reminders, and a WidgetKit extension showing streak/last workout. Core logging works offline on-device. Pro is an optional unlock for unlimited friend saves.”
