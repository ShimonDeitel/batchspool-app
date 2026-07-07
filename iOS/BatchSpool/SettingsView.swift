import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var store: BatchSpoolStore
    @EnvironmentObject private var purchases: PurchaseManager
    @AppStorage("batchspool_haptics_enabled") private var hapticsEnabled: Bool = true
    @AppStorage("batchspool_show_notes") private var showNotes: Bool = true

    @State private var showingDeleteConfirm = false
    @State private var showingPaywall = false
    @State private var showingAdd = false

    var body: some View {
        NavigationStack {
            ZStack {
                BSTheme.backdrop.ignoresSafeArea()

                Form {
                    Section {
                        if purchases.isPro {
                            HStack {
                                Image(systemName: "checkmark.seal.fill").foregroundStyle(BSTheme.accent)
                                Text("Batch Spool Pro active")
                                    .foregroundStyle(BSTheme.ink)
                            }
                        } else {
                            Button {
                                showingPaywall = true
                            } label: {
                                HStack {
                                    Image(systemName: "star.fill").foregroundStyle(BSTheme.accent2)
                                    Text("Unlock Pro")
                                        .foregroundStyle(BSTheme.ink)
                                    Spacer()
                                    Image(systemName: "chevron.right").foregroundStyle(BSTheme.inkFaded)
                                }
                            }
                            .buttonStyle(.plain)
                            .accessibilityIdentifier("settingsUnlockProButton")
                        }
                    }
                    .listRowBackground(BSTheme.card)

                    if purchases.isPro {
                        Section("Low-Stock Alerts & Project Matching") {
                            Text("Low-stock alerts with project floss-usage matching.")
                                .font(.caption)
                                .foregroundStyle(BSTheme.inkFaded)
                            ForEach(store.proEntries) { p in
                                HStack {
                                    Text(p.projectName)
                                        .foregroundStyle(BSTheme.ink)
                                    Spacer()
                                    Text(p.colorNumber)
                                        .font(.caption)
                                        .foregroundStyle(BSTheme.accent)
                                }
                            }
                            .onDelete { offsets in
                                for idx in offsets { store.deleteProEntry(store.proEntries[idx].id) }
                            }
                        }
                        .listRowBackground(BSTheme.card)
                    }

                    Section("Preferences") {
                        Toggle("Haptic Feedback", isOn: $hapticsEnabled)
                            .onChange(of: hapticsEnabled) { _, newValue in
                                BSHaptics.enabled = newValue
                            }
                        Toggle("Show Notes", isOn: $showNotes)
                    }
                    .listRowBackground(BSTheme.card)

                    Section {
                        Button {
                            if store.canAdd(isPro: purchases.isPro) {
                                showingAdd = true
                            } else {
                                showingPaywall = true
                            }
                        } label: {
                            Label("Add Entry", systemImage: "plus")
                        }
                        .accessibilityIdentifier("settingsAddSpoolButton")
                    }
                    .listRowBackground(BSTheme.card)

                    Section {
                        Link("Privacy Policy", destination: URL(string: "https://shimondeitel.github.io/batchspool-app/privacy.html")!)
                        Link("Terms of Use", destination: URL(string: "https://shimondeitel.github.io/batchspool-app/terms.html")!)
                        Button("Restore Purchases") {
                            Task { await purchases.restore() }
                        }
                    }
                    .listRowBackground(BSTheme.card)

                    Section {
                        Button("Delete All Data", role: .destructive) {
                            showingDeleteConfirm = true
                        }
                    }
                    .listRowBackground(BSTheme.card)
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Settings")
            .confirmationDialog("Delete all data? This cannot be undone.", isPresented: $showingDeleteConfirm, titleVisibility: .visible) {
                Button("Delete Everything", role: .destructive) {
                    store.deleteAllData()
                }
                Button("Cancel", role: .cancel) {}
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
            .sheet(isPresented: $showingAdd) {
                SpoolFormView(mode: .add)
            }
        }
    }
}
