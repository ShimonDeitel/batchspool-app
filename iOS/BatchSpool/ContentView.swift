import SwiftUI

struct RootTabView: View {
    var body: some View {
        TabView {
            SpoolListView()
                .tabItem { Label("Home", systemImage: "list.bullet.clipboard") }
            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape") }
        }
        .tint(BSTheme.accent)
    }
}

struct SpoolListView: View {
    @EnvironmentObject private var store: BatchSpoolStore
    @EnvironmentObject private var purchases: PurchaseManager
    @State private var showingAdd = false
    @State private var showingPaywall = false
    @State private var editingItem: Spool?

    var body: some View {
        NavigationStack {
            ZStack {
                BSTheme.backdrop.ignoresSafeArea()
                if store.spools.isEmpty {
                    ContentUnavailableView("No Spools Yet", systemImage: "square.stack.3d.up", description: Text("Tap + to log your first entry."))
                } else {
                    List {
                        ForEach(store.spools) { item in
                            SpoolRow(item: item)
                                .listRowBackground(BSTheme.card)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    editingItem = item
                                }
                                .swipeActions {
                                    Button(role: .destructive) {
                                        store.deleteSpool(item.id)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Batch Spool")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if store.canAdd(isPro: purchases.isPro) {
                            showingAdd = true
                        } else {
                            showingPaywall = true
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                    .accessibilityIdentifier("addSpoolButton")
                }
            }
            .sheet(isPresented: $showingAdd) {
                SpoolFormView(mode: .add)
            }
            .sheet(item: $editingItem) { item in
                SpoolFormView(mode: .edit(item))
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
        }
    }
}

struct SpoolRow: View {
    let item: Spool

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(item.brand)
                .font(BSTheme.headlineFont)
                .foregroundStyle(BSTheme.ink)
            Text(String(describing: item.colorNumber))
                .font(.caption)
                .foregroundStyle(BSTheme.inkFaded)
        }
        .padding(.vertical, 4)
    }
}

enum SpoolFormMode: Identifiable {
    case add
    case edit(Spool)

    var id: String {
        switch self {
        case .add: return "add"
        case .edit(let item): return item.id.uuidString
        }
    }
}

struct SpoolFormView: View {
    @EnvironmentObject private var store: BatchSpoolStore
    @EnvironmentObject private var purchases: PurchaseManager
    @Environment(\.dismiss) private var dismiss

    let mode: SpoolFormMode

    @State private var draftBrand: String = ""
    @State private var draftColorNumber: String = ""
    @State private var draftColorName: String = ""
    @State private var draftQuantityLeft: String = ""

    var body: some View {
        NavigationStack {
            ZStack {
                BSTheme.backdrop.ignoresSafeArea()
                Form {
                    Section {
                Picker("Brand", selection: $draftBrand) {
                    ForEach(BSBrandOption.all, id: \.self) { Text($0) }
                }
                TextField("Color Number", text: $draftColorNumber)
                    .accessibilityIdentifier("colorNumberField")
                TextField("Color Name", text: $draftColorName)
                    .accessibilityIdentifier("colorNameField")
                TextField("Quantity Left (yds)", text: $draftQuantityLeft)
                    .accessibilityIdentifier("quantityLeftField")
                    }
                    .listRowBackground(BSTheme.card)
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle(isEditing ? "Edit Entry" : "New Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                    }
                    .accessibilityIdentifier("spoolSaveButton")
                }
            }
            .onAppear { loadIfEditing() }
            .dismissKeyboardOnTap()
        }
    }

    private var isEditing: Bool {
        if case .edit = mode { return true }
        return false
    }

    private func loadIfEditing() {
        if case .edit(let item) = mode {
        draftBrand = item.brand
        draftColorNumber = item.colorNumber
        draftColorName = item.colorName
        draftQuantityLeft = item.quantityLeft
        } else {
        draftBrand = ""
        draftColorNumber = ""
        draftColorName = ""
        draftQuantityLeft = ""
        }
    }

    private func save() {
        switch mode {
        case .add:
            store.addSpool(draftBrand, draftColorNumber, draftColorName, draftQuantityLeft, isPro: purchases.isPro)
        case .edit(let item):
            store.updateSpool(item.id, draftBrand, draftColorNumber, draftColorName, draftQuantityLeft)
        }
        BSHaptics.success()
        dismiss()
    }
}
