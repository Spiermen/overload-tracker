# DadStrong WidgetKit — one-time Xcode steps

Sources are ready at `ios/App/DadStrongWidget/`.

## Add the target
1. Open `ios/App/App.xcworkspace` in Xcode (after `pod install`).
2. File → New → Target → **Widget Extension**.
3. Product Name: `DadStrongWidget`. Language: Swift. Include Configuration Intent: **No**.
4. Activate scheme if prompted.
5. Delete the stub Swift files Xcode added; keep our:
   - `DadStrongWidget.swift`
   - `Info.plist`
   - `DadStrongWidget.entitlements`
6. Target → Signing & Capabilities → **+ App Groups** → `group.com.spiermen.dadstrong`.
7. App target → same App Group + **HealthKit** + **In-App Purchase**.
8. Embed the widget extension in the App target (Xcode usually does this).

## Verify data flow
Finish a workout in the Simulator/device with the Cap app → `DadStrongBridge.updateWidgetData` writes UserDefaults suite `group.com.spiermen.dadstrong` → widget timeline reloads.

## XcodeGen (optional)
`ios/project.yml` sketches both targets. Capacitor’s generated project is more complete (SPM/Pods); prefer manual target add above unless you maintain a full xcodegen spec.
