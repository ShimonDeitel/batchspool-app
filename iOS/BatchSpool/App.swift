import SwiftUI

@main
struct BatchSpoolApp: App {
    @StateObject private var store = BatchSpoolStore()
    @StateObject private var purchases = PurchaseManager()
    @AppStorage("batchspool_haptics_enabled") private var hapticsEnabled: Bool = true

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environmentObject(store)
                .environmentObject(purchases)
                .preferredColorScheme(.light)
                .onAppear {
                    BSHaptics.enabled = hapticsEnabled
                }
        }
    }
}
