import Foundation

struct Spool: Identifiable, Codable, Equatable {
    let id: UUID
    var brand: String
    var colorNumber: String
    var colorName: String
    var quantityLeft: String
    var createdDate: Date

    init(
        id: UUID = UUID(),
        brand: String = "DMC",
        colorNumber: String = "310",
        colorName: String = "Black",
        quantityLeft: String = "8",
        createdDate: Date = Date()
    ) {
        self.id = id
        self.brand = brand
        self.colorNumber = colorNumber
        self.colorName = colorName
        self.quantityLeft = quantityLeft
        self.createdDate = createdDate
    }
}

/// Pro bonus feature entry: Low-Stock Alerts & Project Matching.
struct BSProEntry: Identifiable, Codable, Equatable {
    let id: UUID
    var projectName: String
    var colorNumber: String
    var yardsNeeded: String
    var lowStockThreshold: String
    var createdDate: Date

    init(
        id: UUID = UUID(),
        projectName: String = "Sampler",
        colorNumber: String = "310",
        yardsNeeded: String = "4",
        lowStockThreshold: String = "3",
        createdDate: Date = Date()
    ) {
        self.id = id
        self.projectName = projectName
        self.colorNumber = colorNumber
        self.yardsNeeded = yardsNeeded
        self.lowStockThreshold = lowStockThreshold
        self.createdDate = createdDate
    }
}

enum BSBrandOption {
    static let all = ["DMC", "Anchor", "Sulky", "Madeira", "Other"]
}
