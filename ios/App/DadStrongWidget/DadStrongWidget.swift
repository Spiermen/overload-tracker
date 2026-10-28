import WidgetKit
import SwiftUI

private let appGroup = "group.com.spiermen.dadstrong"

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> Entry {
        Entry(date: Date(), streak: 3, lastName: "Push", lastDate: Date(), setsThisWeek: 42)
    }
    func getSnapshot(in context: Context, completion: @escaping (Entry) -> ()) {
        completion(load())
    }
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let entry = load()
        completion(Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(60 * 30))))
    }
    private func load() -> Entry {
        let d = UserDefaults(suiteName: appGroup) ?? .standard
        let streak = d.integer(forKey: "streak")
        let lastName = d.string(forKey: "lastName") ?? ""
        let lastMs = d.double(forKey: "lastDate")
        let sets = d.integer(forKey: "setsThisWeek")
        let last = lastMs > 0 ? Date(timeIntervalSince1970: lastMs / 1000) : nil
        return Entry(date: Date(), streak: streak, lastName: lastName, lastDate: last, setsThisWeek: sets)
    }
}

struct Entry: TimelineEntry {
    let date: Date
    let streak: Int
    let lastName: String
    let lastDate: Date?
    let setsThisWeek: Int
}

struct DadStrongWidgetEntryView: View {
    var entry: Entry
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("DadStrong")
                    .font(.caption.weight(.heavy))
                    .foregroundStyle(Color(red: 0.90, green: 0.15, blue: 0.21))
                Spacer()
                Text("🔥 \(entry.streak)w")
                    .font(.caption.weight(.bold))
            }
            if entry.lastName.isEmpty {
                Text("Log a workout")
                    .font(.headline)
                Text("Streak & last session show here.")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            } else {
                Text(entry.lastName)
                    .font(.headline)
                    .lineLimit(1)
                if let d = entry.lastDate {
                    Text(d, style: .relative)
                        .font(.caption2)
                        .foregroundStyle(.secondary) + Text(" ago")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                Text("\(entry.setsThisWeek) sets this week")
                    .font(.caption.weight(.semibold))
            }
            Spacer(minLength: 0)
        }
        .padding(12)
        .containerBackground(for: .widget) {
            Color(red: 0.04, green: 0.04, blue: 0.04)
        }
    }
}

@main
struct DadStrongWidget: Widget {
    let kind = "DadStrongWidget"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            DadStrongWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("DadStrong")
        .description("Week streak and your last workout.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
