import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var purchases: PurchaseManager
    @Environment(\.dismiss) private var dismiss
    @AppStorage("tanline_showNotes") private var showNotes: Bool = true
    @AppStorage("tanline_showDates") private var showDates: Bool = true

    var body: some View {
        NavigationStack {
            Form {
                Section("Display") {
                    Toggle("Show notes", isOn: $showNotes)
                    Toggle("Show dates", isOn: $showDates)
                }
                Section("Tanline Pro") {
                    if purchases.isPurchased {
                        Label("Pro unlocked", systemImage: "checkmark.seal.fill")
                            .foregroundStyle(Theme.accent)
                    } else {
                        Button("Upgrade to Pro") {
                            // handled via PaywallView from main screen
                        }
                    }
                    Button("Restore Purchases") {
                        Task { await purchases.restore() }
                    }
                    .accessibilityIdentifier("restoreButton")
                }
                Section("About") {
                    Link("Privacy Policy", destination: URL(string: "https://shimondeitel.github.io/tanline-app/privacy.html")!)
                    Link("Terms of Use", destination: URL(string: "https://shimondeitel.github.io/tanline-app/terms.html")!)
                    Text("Tanline v1.0")
                        .foregroundStyle(Theme.muted)
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .accessibilityIdentifier("settingsDoneButton")
                }
            }
        }
    }
}
