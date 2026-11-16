import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss

    @AppStorage("appTheme") private var theme = "system"
    @AppStorage("useLargeText") private var useLargeText = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Вигляд") {
                    Picker("Тема", selection: $theme) {
                        Text("Системна").tag("system")
                        Text("Світла").tag("light")
                        Text("Темна").tag("dark")
                    }

                    Toggle("Збільшений текст", isOn: $useLargeText)
                }
            }
            .navigationTitle("Налаштування")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Готово") {
                        dismiss()
                    }
                }
            }
        }
    }
}
