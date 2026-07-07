import Foundation

@MainActor
final class BatchSpoolStore: ObservableObject {
    @Published private(set) var spools: [Spool] = []
    @Published private(set) var proEntries: [BSProEntry] = []

    static let freeLimit = 30

    private let fileURL: URL
    private let proFileURL: URL

    init() {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        self.fileURL = dir.appendingPathComponent("batchspool_spools.json")
        self.proFileURL = dir.appendingPathComponent("batchspool_pro.json")
        if ProcessInfo.processInfo.arguments.contains("-uiTestReset") {
            try? FileManager.default.removeItem(at: fileURL)
            try? FileManager.default.removeItem(at: proFileURL)
        }
        load()
        if spools.isEmpty {
            seedDefaults()
        }
        if proEntries.isEmpty {
            seedProDefaults()
        }
    }

    private func seedDefaults() {
        spools = [
            Spool(brand: "DMC", colorNumber: "310", colorName: "Black", quantityLeft: "8"),
            Spool(brand: "DMC", colorNumber: "666", colorName: "Bright Red", quantityLeft: "5"),
            Spool(brand: "Anchor", colorNumber: "9046", colorName: "Coral", quantityLeft: "3")
        ]
        save()
    }

    private func seedProDefaults() {
        proEntries = [
            BSProEntry(projectName: "Sampler", colorNumber: "310", yardsNeeded: "4", lowStockThreshold: "3"),
            BSProEntry(projectName: "Floral Hoop", colorNumber: "666", yardsNeeded: "6", lowStockThreshold: "3")
        ]
        saveProEntries()
    }

    func canAdd(isPro: Bool) -> Bool {
        isPro || spools.count < Self.freeLimit
    }

    @discardableResult
    func addSpool(brand: String, colorNumber: String, colorName: String, quantityLeft: String, isPro: Bool) -> Bool {
        let trimmed = colorNumber.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, canAdd(isPro: isPro) else { return false }
        let item = Spool(brand: brand, colorNumber: colorNumber, colorName: colorName, quantityLeft: quantityLeft)
        spools.append(item)
        save()
        return true
    }

    func updateSpool(_ id: UUID, brand: String, colorNumber: String, colorName: String, quantityLeft: String) {
        guard let idx = spools.firstIndex(where: { $0.id == id }) else { return }
        spools[idx].brand = brand
        spools[idx].colorNumber = colorNumber
        spools[idx].colorName = colorName
        spools[idx].quantityLeft = quantityLeft
        save()
    }

    func deleteSpool(_ id: UUID) {
        spools.removeAll { $0.id == id }
        save()
    }

    func deleteAllData() {
        spools = []
        proEntries = []
        seedDefaults()
        seedProDefaults()
    }

    // MARK: - Pro entries

    @discardableResult
    func addProEntry(projectName: String, colorNumber: String, yardsNeeded: String, lowStockThreshold: String) -> Bool {
        let entry = BSProEntry(projectName: projectName, colorNumber: colorNumber, yardsNeeded: yardsNeeded, lowStockThreshold: lowStockThreshold)
        proEntries.append(entry)
        saveProEntries()
        return true
    }

    func deleteProEntry(_ id: UUID) {
        proEntries.removeAll { $0.id == id }
        saveProEntries()
    }

    // MARK: - Persistence

    private struct Snapshot: Codable {
        var items: [Spool]
    }
    private struct ProSnapshot: Codable {
        var items: [BSProEntry]
    }

    private func load() {
        if let data = try? Data(contentsOf: fileURL), let decoded = try? JSONDecoder().decode(Snapshot.self, from: data) {
            spools = decoded.items
        }
        if let data = try? Data(contentsOf: proFileURL), let decoded = try? JSONDecoder().decode(ProSnapshot.self, from: data) {
            proEntries = decoded.items
        }
    }

    private func save() {
        let snapshot = Snapshot(items: spools)
        guard let data = try? JSONEncoder().encode(snapshot) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }

    private func saveProEntries() {
        let snapshot = ProSnapshot(items: proEntries)
        guard let data = try? JSONEncoder().encode(snapshot) else { return }
        try? data.write(to: proFileURL, options: .atomic)
    }
}
