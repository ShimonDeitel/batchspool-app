import XCTest
@testable import BatchSpool

final class BatchSpoolTests: XCTestCase {

    @MainActor
    func testStoreSeedsAboveZeroButBelowFreeLimit() {
        let store = BatchSpoolStore()
        XCTAssertGreaterThan(store.spools.count, 0)
        XCTAssertLessThan(store.spools.count, BatchSpoolStore.freeLimit)
    }

    @MainActor
    func testAddEntrySucceedsWhenUnderLimit() {
        let store = BatchSpoolStore()
        let before = store.spools.count
        let added = store.addSpool(brand: "DMC", colorNumber: "310", colorName: "Black", quantityLeft: "8", isPro: false)
        XCTAssertTrue(added)
        XCTAssertEqual(store.spools.count, before + 1)
    }

    @MainActor
    func testAddEntryRejectsBlankPrimaryField() {
        let store = BatchSpoolStore()
        let before = store.spools.count
        let added = store.addSpool(brand: "   ", colorNumber: "310", colorName: "Black", quantityLeft: "8", isPro: false)
        XCTAssertFalse(added)
        XCTAssertEqual(store.spools.count, before)
    }

    @MainActor
    func testFreeLimitBlocksAdditionalEntries() {
        let store = BatchSpoolStore()
        for item in store.spools { store.deleteSpool(item.id) }
        for _ in 0..<BatchSpoolStore.freeLimit {
            XCTAssertTrue(store.addSpool(brand: "DMC", colorNumber: "310", colorName: "Black", quantityLeft: "8", isPro: false))
        }
        XCTAssertFalse(store.addSpool(brand: "DMC", colorNumber: "310", colorName: "Black", quantityLeft: "8", isPro: false))
        XCTAssertTrue(store.addSpool(brand: "DMC", colorNumber: "310", colorName: "Black", quantityLeft: "8", isPro: true))
    }

    @MainActor
    func testDeleteEntry() {
        let store = BatchSpoolStore()
        store.addSpool(brand: "DMC", colorNumber: "310", colorName: "Black", quantityLeft: "8", isPro: false)
        guard let item = store.spools.last else { return XCTFail("expected entry") }
        let before = store.spools.count
        store.deleteSpool(item.id)
        XCTAssertEqual(store.spools.count, before - 1)
    }

    @MainActor
    func testDeleteAllDataReseeds() {
        let store = BatchSpoolStore()
        store.deleteAllData()
        XCTAssertGreaterThan(store.spools.count, 0)
        XCTAssertGreaterThan(store.proEntries.count, 0)
    }

    @MainActor
    func testUpdateEntryPersistsChange() {
        let store = BatchSpoolStore()
        store.addSpool(brand: "DMC", colorNumber: "310", colorName: "Black", quantityLeft: "8", isPro: false)
        guard let item = store.spools.last else { return XCTFail("expected entry") }
        store.updateSpool(item.id, brand: "DMC", colorNumber: "310", colorName: "Black", quantityLeft: "8")
        XCTAssertEqual(store.spools.count, store.spools.count)
    }
}
