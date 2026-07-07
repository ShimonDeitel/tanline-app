import Foundation
import Combine

@MainActor
final class Store: ObservableObject {
    @Published private(set) var entries: [SessionEntry] = []
    @Published var isPro: Bool = false

    // Free tier limit is intentionally well above the seed data count
    // so a fresh install never hits the paywall immediately.
    static let freeLimit = 8

    private let fileName = "tanline_entries.json"

    private var fileURL: URL {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        if !FileManager.default.fileExists(atPath: dir.path) {
            try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir.appendingPathComponent(fileName)
    }

    init() {
        load()
    }

    var canAddMore: Bool {
        isPro || entries.count < Store.freeLimit
    }

    func add(_ entry: SessionEntry) {
        entries.insert(entry, at: 0)
        save()
    }

    func update(_ entry: SessionEntry) {
        guard let idx = entries.firstIndex(where: { $0.id == entry.id }) else { return }
        entries[idx] = entry
        save()
    }

    func delete(at offsets: IndexSet) {
        entries.remove(atOffsets: offsets)
        save()
    }

    func delete(_ entry: SessionEntry) {
        entries.removeAll { $0.id == entry.id }
        save()
    }

    private func load() {
        if let data = try? Data(contentsOf: fileURL),
           let decoded = try? JSONDecoder().decode([SessionEntry].self, from: data) {
            entries = decoded
        } else {
            entries = Self.seedData()
            save()
        }
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(entries) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }

    static func seedData() -> [SessionEntry] {
        let now = Date()
        return [
            SessionEntry(title: "Sample Session One", detail1: "Example", detail2: "Example", note: "Tap + to add your own.", date: now),
            SessionEntry(title: "Sample Session Two", detail1: "Example", detail2: "Example", note: "", date: now.addingTimeInterval(-86400))
        ]
    }
}
