import Foundation
import Capacitor
import HealthKit
import WidgetKit

@objc(DadStrongBridgePlugin)
public class DadStrongBridgePlugin: CAPPlugin, CAPBridgedPlugin {
    public let identifier = "DadStrongBridgePlugin"
    public let jsName = "DadStrongBridge"
    public let pluginMethods: [CAPPluginMethod] = [
        CAPPluginMethod(name: "isNative", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "requestHealthAuth", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "saveWorkout", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "updateWidgetData", returnType: CAPPluginReturnPromise)
    ]

    private let store = HKHealthStore()
    private let appGroup = "group.com.spiermen.dadstrong"

    @objc func isNative(_ call: CAPPluginCall) {
        call.resolve(["native": true, "platform": "ios"])
    }

    @objc func requestHealthAuth(_ call: CAPPluginCall) {
        guard HKHealthStore.isHealthDataAvailable() else {
            call.reject("HealthKit unavailable")
            return
        }
        let types: Set<HKSampleType> = [HKObjectType.workoutType()]
        store.requestAuthorization(toShare: types, read: types) { ok, err in
            DispatchQueue.main.async {
                if let err = err { call.reject(err.localizedDescription); return }
                call.resolve(["granted": ok])
            }
        }
    }

    @objc func saveWorkout(_ call: CAPPluginCall) {
        guard HKHealthStore.isHealthDataAvailable() else {
            call.reject("HealthKit unavailable")
            return
        }
        let startMs = call.getDouble("start") ?? 0
        let endMs = call.getDouble("end") ?? Date().timeIntervalSince1970 * 1000
        let name = call.getString("name") ?? "Strength"
        let start = Date(timeIntervalSince1970: startMs / 1000)
        let end = Date(timeIntervalSince1970: endMs / 1000)
        guard end > start else { call.reject("Invalid workout dates"); return }

        let activity: HKWorkoutActivityType = {
            let n = name.lowercased()
            if n.contains("run") { return .running }
            if n.contains("walk") { return .walking }
            if n.contains("cycle") || n.contains("bike") { return .cycling }
            return .traditionalStrengthTraining
        }()

        let workout = HKWorkout(
            activityType: activity,
            start: start,
            end: end,
            duration: end.timeIntervalSince(start),
            totalEnergyBurned: nil,
            totalDistance: nil,
            metadata: [HKMetadataKeyWorkoutBrandName: "DadStrong", "name": name]
        )

        store.save(workout) { ok, err in
            DispatchQueue.main.async {
                if let err = err { call.reject(err.localizedDescription); return }
                call.resolve(["saved": ok, "id": workout.uuid.uuidString])
            }
        }
    }

    @objc func updateWidgetData(_ call: CAPPluginCall) {
        let streak = call.getInt("streak") ?? 0
        let lastName = call.getString("lastName") ?? ""
        let lastDate = call.getDouble("lastDate") ?? 0
        let sets = call.getInt("setsThisWeek") ?? 0
        let defaults = UserDefaults(suiteName: appGroup) ?? UserDefaults.standard
        defaults.set(streak, forKey: "streak")
        defaults.set(lastName, forKey: "lastName")
        defaults.set(lastDate, forKey: "lastDate")
        defaults.set(sets, forKey: "setsThisWeek")
        defaults.set(Date().timeIntervalSince1970, forKey: "updatedAt")
        defaults.synchronize()
        if #available(iOS 14.0, *) {
            WidgetCenter.shared.reloadAllTimelines()
        }
        call.resolve(["ok": true])
    }
}
